//
//  FollowingItemViewController.m
//  DealInterest2
//
//  Created by xiaoming on 7/8/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "FollowingItemViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "AppDelegate.h"
#import <SVPullToRefresh.h>

@interface FollowingItemViewController ()

@property NSMutableArray *itemData;
@property NSIndexPath *selectedCellIndexPath;
@property NSInteger currentPage;
@end

@implementation FollowingItemViewController

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
    
    self.currentPage = 1;
    
    __weak FollowingItemViewController *tmpSelf= self;
    [self.collectionView addPullToRefreshWithActionHandler:^{
        // prepend data to dataSource, insert cells at top of table view
        // call [tableView.pullToRefreshView stopAnimating] when done
        [tmpSelf getLatestItem:YES infiniteScroll:NO];
    }];
    
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        // append data to data source, insert new cells at the end of table view
        // call [tableView.infiniteScrollingView stopAnimating] when done
        [tmpSelf getLatestItem:NO infiniteScroll:YES];
    }];
    [self getLatestItem:NO infiniteScroll:NO];
}

-(void)getLatestItem:(BOOL)isPullToRefresh infiniteScroll:(BOOL)infiniteScroll {
    // Setup the activity indicator
    MBProgressHUD *hud;
    if(isPullToRefresh) {
        self.currentPage = 1;
    } else if (infiniteScroll) {
        self.currentPage++;
    } else {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/item.getFollowingItem/"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    NSDictionary *parameters = @{@"user_id": userID, @"page": @(self.currentPage)};
    NSLog(@"Get Latest Item");
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        if ([responseObject[@"is_last_row"] intValue]) {
            self.collectionView.showsInfiniteScrolling = NO;
        }
        
        if (isPullToRefresh) {
            self.itemData = [responseObject[@"item"] mutableCopy];
            [self.collectionView.pullToRefreshView stopAnimating];
        } else if (infiniteScroll) {
            [self.itemData addObjectsFromArray:[responseObject[@"item"] mutableCopy]];
            [self.collectionView.infiniteScrollingView stopAnimating];
        } else {
            self.itemData = [responseObject[@"item"] mutableCopy];
            [hud hide:YES];
        }
        
        [self.collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"%@", [NSString stringWithFormat:@"%@%@", ServerBaseUrl, item[@"photo1"]]);
    
    // Get the ImageView of this cell
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    
    // Load the image into the cell's ImageView
    NSURL *imgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, item[@"photo"]]];
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
    itemName.text = item[@"title"];
    
    // Update the price of this item
    UILabel *itemPrice = (UILabel *)[cell viewWithTag:103];
    itemPrice.text = [NSString stringWithFormat:@"$%.2f", [item[@"price"] floatValue]];
    
    // Update the like no of this item
    UILabel *itemNoOfLike = (UILabel *)[cell viewWithTag:104];
    itemNoOfLike.text = [NSString stringWithFormat:@"%ld", (long)[item[@"like_no"] integerValue]];
    
    // Update the comment no of this item
    UILabel *itemNoOfComment = (UILabel *)[cell viewWithTag:105];
    itemNoOfComment.text = [NSString stringWithFormat:@"%ld", (long)[item[@"comment_no"] integerValue]];
    
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
    
    // Get the ImageView of this cell
    UIImageView *profilePicImageView = (UIImageView *)[cell viewWithTag:107];
    
    // Load the profile pic
    imgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, item[@"profile_pic"]]];
    [profilePicImageView setImageWithURL:imgUrl placeholderImage:nil];
    profilePicImageView.layer.masksToBounds = YES;
    profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width/2;
    
    // Update the comment no of this item
    UILabel *itemUsername = (UILabel *)[cell viewWithTag:108];
    itemUsername.text = item[@"name"];
    
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 4.0f;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCellIndexPath = indexPath;
    
    // Get category data for the selected cell
    NSDictionary *item = [self.itemData objectAtIndex:indexPath.row];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showItemScreen:[item[@"item_id"] integerValue] itemName:item[@"title"] isEditable:NO navController:self.navigationController];
    
}

- (IBAction)likeItem:(id)sender {
    UIButton *button = (UIButton *) sender;
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[[button superview] superview];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    NSMutableDictionary *item = [[self.itemData objectAtIndex:indexPath.row] mutableCopy];
    
    NSString *url;
    if ([item[@"liked"] integerValue] == 1) {
        url = [NSString stringWithFormat:@"%@json/favourite.remove/", ServerBaseUrl];
    } else {
        url = [NSString stringWithFormat:@"%@json/favourite.insert/", ServerBaseUrl];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    NSString *deviceID = [prefs objectForKey:@"deviceID"];
    NSString *token = [prefs objectForKey:@"token"];
    
    // Prepare the favourite JSON URL
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"item_id": item[@"item_id"],
                                 @"user_id": userID,
                                 @"device_id": deviceID,
                                 @"token": token
                                 };
    //NSLog(@"params: %@", parameters);
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        // flip
        if ([item[@"liked"] integerValue] == 1) {
            item[@"liked"] = @0;
        } else {
            item[@"liked"] = @1;
        }
        self.itemData[indexPath.row] = item;
        
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } failure:nil];
    
}


@end
