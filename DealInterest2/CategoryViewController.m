//
//  TestViewController.m
//  DealInterest2
//
//  Created by xiaoming on 4/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "CategoryViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "AppDelegate.h"
#import <SVPullToRefresh.h>
#import "SearchFilterTableViewController.h"

@interface CategoryViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *categoryTableMessage;
@property NSMutableArray *itemData;
@property UIRefreshControl *refreshControl;
@property NSIndexPath *selectedCellIndexPath;
@end

@implementation CategoryViewController

- (IBAction)likeItem:(id)sender {
    UIButton *button = (UIButton *) sender;
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[[button superview] superview];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    
    // Setup the activity indicator
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableDictionary *item = [[self.itemData objectAtIndex:indexPath.row] mutableCopy];
    
    NSString *url;
    if ([item[@"liked"] integerValue] == 1) {
        url = [NSString stringWithFormat:@"%@json/favourite.remove/", ServerBaseUrl];
       // hud.labelText = @"Unlike the item";
    } else {
        url = [NSString stringWithFormat:@"%@json/favourite.insert/", ServerBaseUrl];
       // hud.labelText = @"Liking the item";
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    NSString *deviceID = [prefs objectForKey:@"deviceID"];
    NSString *token = [prefs objectForKey:@"token"];
    
    // Prepare the favourite JSON URL
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"item_id": item[@"pk"],
                                 @"user_id": userID,
                                 @"device_id": deviceID,
                                 @"token": token
                                 };
    //NSLog(@"params: %@", parameters);
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if ([self.function isEqualToString:@"StuffILiked"])  {
            [self.itemData removeObjectAtIndex:indexPath.row];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        } else {
            // flip
            if ([item[@"liked"] integerValue] == 1) {
                item[@"liked"] = @0;
            } else {
                item[@"liked"] = @1;
            }
            self.itemData[indexPath.row] = item;
            
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
        // Hide the activity indicator
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"self.collectionView.frame x = %f", self.collectionView.frame.origin.x);
    
    self.itemData = nil;
    
    self.sortBy = 0; // Sort by most recent
    self.priceRangeFrom = 0.0;
    self.priceRangeTo = 0.0;
    
    NSLog(@"Category Page");
    
    if ([self.function isEqualToString:@"StuffILiked"]) {
        self.title = @"Stuff I Liked";
        
        [self getStuffILikeItem];
    } else {
        // Update the navigation bar title with the category name
        self.title = self.categoryName;
        
        __weak CategoryViewController *tmpSelf= self;
        [self.collectionView addPullToRefreshWithActionHandler:^{
            // prepend data to dataSource, insert cells at top of table view
            // call [tableView.pullToRefreshView stopAnimating] when done
            [tmpSelf getCategoryItem:YES];
        }];
        
        [self getCategoryItem:NO];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCategoryItemLike:)
                                                 name:@"RefreshCategoryItemLikeNotification"
                                               object:nil];
    
}


-(void)refreshCategoryItemLike:(NSNotification *)notification {
    NSLog(@"Refresh Item Cell Like");
    
    
    NSMutableDictionary *item = [[self.itemData objectAtIndex:self.selectedCellIndexPath.row] mutableCopy];
    
    NSDictionary *userInfo = [notification userInfo];
    item[@"liked"] = userInfo[@"liked"];
    self.itemData[self.selectedCellIndexPath.row] = item;
    
    [self.collectionView reloadItemsAtIndexPaths:@[self.selectedCellIndexPath]];
}

-(void)getStuffILikeItem {
    self.searchBar.hidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    // Setup the URL for fetching the JSON from the server which contain all the item for this category
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/favourite.getItem2/"];
    
    NSDictionary *parameters = @{@"user_id": userID};
    
    // Use GET request
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self configureCategoryCollection:responseObject isPullToRefresh:NO];
    } failure:nil];
}

-(void)getCategoryItem:(BOOL)isPullToRefresh {
    // Setup the activity indicator
    if(!isPullToRefresh) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
    } else {
        [self searchBarCancelButtonClicked:self.searchBar];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Setup the URL for fetching the JSON from the server which contain all the item for this category
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/browse.getItemList2/"];
    
    NSDictionary *parameters = @{@"category": self.categoryName, @"user_id": userID};
    NSLog(@"cat url = %@", url);
    
    // Use POST request
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [self configureCategoryCollection:responseObject isPullToRefresh:isPullToRefresh];
    } failure:nil];
}

-(void)configureCategoryCollection:(id)responseObject isPullToRefresh:(BOOL)isPullToRefresh {
    if ([responseObject count] > 0) {
        NSString *responseText = [responseObject objectAtIndex:0][@"responseText"];
        if ([responseText isEqualToString:@"Success!"]) {
            // Store the category's item JSON into array for later use
            self.itemData = [responseObject mutableCopy];
        }
        self.categoryTableMessage.hidden = YES;
    } else {
        self.categoryTableMessage.text = @"No item found";
        self.categoryTableMessage.hidden = NO;
    }
    
    
    if (!isPullToRefresh) {
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } else {
        //[NSThread sleepForTimeInterval:1];
        [self.collectionView.pullToRefreshView stopAnimating];
    }
    
    
    // Update the screen
    [self.collectionView reloadData];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.function isEqualToString:@"StuffILiked"]) {
        self.collectionView.frame = CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height + self.searchBar.frame.size.height);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// http://mishravinay.wordpress.com/2014/02/28/idev-uisearchbar-tricks-showing-the-cancel-and-the-scope-bar-only-when-editing/
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    return YES;
}

// http://stackoverflow.com/questions/19531199/enable-search-button-for-uisearchbar-when-field-is-empty-ios-7
- (void)searchBarTextDidBeginEditing:(UISearchBar *) bar
{
    UITextField *searchBarTextField = nil;
    NSArray *views = ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) ? bar.subviews : [[bar.subviews objectAtIndex:0] subviews];
    for (UIView *subview in views)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchBarTextField = (UITextField *)subview;
            break;
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search");
    [searchBar resignFirstResponder];
    // Do the search...
    
    NSLog(@"%@", searchBar.text);
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Searching %@", searchBar.text];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"search": searchBar.text,
                                 @"category": self.categoryName,
                                 @"sort_by": @(self.sortBy),
                                 @"price_from": @(self.priceRangeFrom),
                                 @"price_to": @(self.priceRangeTo),
                                 @"user_id": userID
                                 };
    
    NSLog(@"parameter = %@", parameters);
    [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/search.searchItem2/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON %@", responseObject);
        
        // Store the category's item JSON into array for later use
        if ([responseObject[@"items"] count] > 0) {
            self.itemData = [responseObject[@"items"] mutableCopy];
            self.categoryTableMessage.hidden = YES;
        } else {
            self.itemData = nil;
            self.categoryTableMessage.text = @"No item found";
            self.categoryTableMessage.hidden = NO;
        }
        // Update the screen
        [self.collectionView reloadData];
        
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Cancel");
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ItemCell";
    
    // Get the cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // Get the activity indicator inside the cell
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:102];
    
    // Extract the item data from array needed for this specific cell
    NSDictionary *item = [self.itemData objectAtIndex:indexPath.row];
    NSLog(@"%@", [NSString stringWithFormat:@"%@%@", ServerBaseUrl, item[@"fields"][@"photo1"]]);
    
    // Get the ImageView of this cell
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    
    // Load the image into the cell's ImageView
    NSURL *imgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, item[@"fields"][@"photo1"]]];
    [cellImageView setImageWithURL:imgUrl placeholderImage:nil options:SDWebImageRetryFailed  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        [activityIndicator startAnimating];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [activityIndicator stopAnimating];
        // Show error if there is any problems
        if (error) {
            NSLog(@" error => %@ ", [error userInfo] );
            NSLog(@" error => %@ ", [error localizedDescription] );
        }
    }];
    
    // Update the name of this item
    UILabel *itemName = (UILabel *)[cell viewWithTag:101];
    itemName.text = item[@"fields"][@"title"];
    
    // Update the price of this item
    UILabel *itemPrice = (UILabel *)[cell viewWithTag:103];
    itemPrice.text = [NSString stringWithFormat:@"$%.2f", [item[@"fields"][@"price"] floatValue]];
    
    // Update the like no of this item
    UILabel *itemNoOfLike = (UILabel *)[cell viewWithTag:104];
    itemNoOfLike.text = [NSString stringWithFormat:@"%ld", (long)[item[@"fields"][@"like_no"] integerValue]];
    
    // Update the comment no of this item
    UILabel *itemNoOfComment = (UILabel *)[cell viewWithTag:105];
    itemNoOfComment.text = [NSString stringWithFormat:@"%ld", (long)[item[@"fields"][@"comment_no"] integerValue]];
    
    // Add border to cell. Find color at http://uicolor.org/
    //cell.layer.borderWidth=1.0f;
    //UIColor * color = [UIColor colorWithRed:206/255.0f green:206/255.0f blue:206/255.0f alpha:1.0f];
    //cell.layer.borderColor= color.CGColor;
    
    UIImageView *heartImageView = (UIImageView *)[cell viewWithTag:106];
    if ([item[@"liked"] integerValue] == 1) {
        heartImageView.image = [UIImage imageNamed:@"heart_red"];
    } else {
        heartImageView.image = [UIImage imageNamed:@"heart_grey"];
    }
    
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 4.0f;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCellIndexPath = indexPath;
    
    // Get category data for the selected cell
    NSDictionary *item = [self.itemData objectAtIndex:indexPath.row];
    
    NSLog(@"clickec = title =  %@", item[@"fields"][@"title"]);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showItemScreen:[item[@"pk"] integerValue] itemName:item[@"fields"][@"title"] isEditable:NO navController:self.navigationController];
   
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToFilterPage"])
    {
         // Get the category controller
        UINavigationController *navController = [segue destinationViewController];
        SearchFilterTableViewController *destViewController = (SearchFilterTableViewController *)([navController viewControllers][0]);
        destViewController.delegate = self;
        destViewController.sortBy = self.sortBy;
        destViewController.priceRangeFrom = self.priceRangeFrom;
        destViewController.priceRangeTo = self.priceRangeTo;
    }
}
@end
