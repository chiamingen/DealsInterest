//
//  ItemTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 24/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ItemTableViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "ImagePageViewController.h"
#import "ImagePageContentViewController.h"
#import "CommentViewController.h"
// #import "UIImageView+AFNetworking.h"

@interface ItemTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *commentTabelCell;

@property (weak, nonatomic) IBOutlet UIView *commentContainer;
@property ImagePageViewController *imagePage;

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *itemDate;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UILabel *itemPrice;
@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UILabel *itemNoOfLikes;
@property (weak, nonatomic) IBOutlet UIImageView *itemLocationMap;

@property (weak, nonatomic) IBOutlet UIButton *viewAllCommentButton;
@property (weak, nonatomic) IBOutlet UILabel *itemLocationName;
@property (weak, nonatomic) IBOutlet UILabel *itemLocationAddress;

@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;

@property (nonatomic, strong) LPGoogleFunctions *googleFunctions;

@property NSInteger noOfComments;

@property ItemCommentTableViewController *commentPage;
@property BOOL hasComment;
@end

@implementation ItemTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hasComment = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCommentView:)
                                                 name:@"RefreshCommentViewNotification"
                                               object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (IBAction)clickLikeButton:(id)sender {
    
    NSString *url;
    if ([self.itemData[@"liked"] integerValue] == 1) {
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
                                 @"item_id": self.itemData[@"pk"],
                                 @"user_id": userID,
                                 @"device_id": deviceID,
                                 @"token": token
                                 };
    //NSLog(@"params: %@", parameters);
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([self.itemData[@"liked"] integerValue] == 1) {
            self.itemData[@"liked"] = @0;
            self.heartImageView.image = [UIImage imageNamed:@"heart_grey"];
        } else {
            self.itemData[@"liked"] = @1;
             self.heartImageView.image = [UIImage imageNamed:@"heart_red"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCategoryItemLikeNotification" object:self userInfo:@{@"liked": self.itemData[@"liked"]}];
        // Hide the activity indicator
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
    

}

- (IBAction)clickProfile:(id)sender {
    // Show login screen
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showOthersProfileScreen:YES otherUserID:self.itemData[@"fields"][@"user_id"] navController:self.navigationController];
}


-(void)refreshCommentView:(NSNotification *)notification {
    self.hasComment = YES;
    self.commentPage.commentData = [notification.userInfo objectForKey:@"comments"];
    [self.commentPage.tableView reloadData];
    [self.tableView reloadData];
    
    self.noOfComments++;
    NSString *buttonTitle = [NSString stringWithFormat:@"View all %ld comments", (long)self.noOfComments];
    [self.viewAllCommentButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    NSLog(@"Refresh Comment View");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData {
    self.userName.text = self.itemData[@"fields"][@"user_name"];
    self.itemPrice.text = [NSString stringWithFormat:@"$%.2f", [self.itemData[@"fields"][@"price"] floatValue]];
    // self.priceToolbar.title = self.price.text;
    self.itemTitle.text = self.itemData[@"fields"][@"title"];
    self.title = self.itemTitle.text;
    self.itemDescription.text = self.itemData[@"fields"][@"description"];
    self.itemNoOfLikes.text = [NSString stringWithFormat:@"%@ likes", self.itemData[@"fields"][@"like_no"]];
    // self.itemLocation.text = self.itemData[@"fields"][@"location_address"];
    self.itemDate.text = [Helper calculateDate:self.itemData[@"fields"][@"date"]];
    
    // Load user profile pic
    NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, self.itemData[@"fields"][@"profile_pic"]]];
    [self.profilePic setImageWithURL:profilePicUrl];

    // Configure heart image
    if ([self.itemData[@"liked"] integerValue] == 1) {
        self.heartImageView.image = [UIImage imageNamed:@"heart_red"];
    } else {
        self.heartImageView.image = [UIImage imageNamed:@"heart_grey"];
    }
    
    // Load item Image
    NSMutableArray *images = [NSMutableArray arrayWithObjects: self.itemData[@"fields"][@"photo1"], nil];
    
    if (![self.itemData[@"fields"][@"photo2"] isEqualToString:@""]) {
        [images addObject:self.itemData[@"fields"][@"photo2"]];
    }
    
    self.imagePage.pageImages = images;
    // Create a new view controller and pass suitable data.
    ImagePageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImagePageContentViewController"];
    pageContentViewController.imageFile =  self.imagePage.pageImages[0];
    pageContentViewController.pageIndex = 0;
    [self.imagePage setViewControllers:@[pageContentViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Load comments
    NSArray *comments = self.itemData[@"comments"];
    if ([comments count] > 0) {
       self.commentPage.commentData = [comments mutableCopy];
        self.hasComment = YES;
    } else {
        self.commentPage.commentData = [[NSMutableArray alloc] init];
        self.hasComment = NO;
    }
    
    self.noOfComments = [self.itemData[@"fields"][@"comment_no"] integerValue];
    NSString *buttonTitle = [NSString stringWithFormat:@"View all %ld comments", (long)self.noOfComments];
    [self.viewAllCommentButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    [self.commentPage.tableView reloadData];
    
    // Load map
    double lat = [self.itemData[@"fields"][@"lat"] doubleValue];
    double lng = [self.itemData[@"fields"][@"lng"] doubleValue];
    
    self.itemLocationName.text = self.itemData[@"fields"][@"location_name"];
    self.itemLocationAddress.text = self.itemData[@"fields"][@"location_address"];
    
    if (lat == 0.0 && lng == 0.0) {
        self.itemLocationMap.hidden = YES;
    } else {
        self.itemLocationMap.hidden = NO;
        
        NSMutableArray *markers = [NSMutableArray new];
        
        LPMapImageMarker *marker1 = [LPMapImageMarker new];
        marker1.size = LPGoogleMapImageMarkerSizeNormal;
        marker1.location = [LPLocation locationWithLatitude:lat longitude:lng];
        //marker1.label = self.itemData[@"fields"][@"location_name"];
        marker1.color = [UIColor redColor];
        [markers addObject:marker1];
        
        [self.googleFunctions loadStaticMapImageForLocation:[LPLocation locationWithLatitude:lat longitude:lng] zoomLevel:16 imageSize:CGSizeMake(self.itemLocationMap.frame.size.width,self.itemLocationMap.frame.size.height) imageScale:2 mapType:LPGoogleMapTypeTerrain markersArray:markers successfulBlock:^(UIImage *image) {
            
            [self.itemLocationMap setImage:image];
            
        } failureBlock:^(NSError *error) {
            
            NSLog(@"Error: %@",error);
            
        }];
    }
    
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToItemCommentScreen"])
    {
        
        ItemCommentTableViewController *destViewController = segue.destinationViewController;
        self.commentPage = destViewController;
    } else if ([[segue identifier] isEqualToString:@"goToImagePageScreen"]) {
        NSLog(@"goToImagePageScreen");
        ImagePageViewController *destViewController = segue.destinationViewController;
        self.imagePage = destViewController;
    } else if ([[segue identifier] isEqualToString:@"goToCommentPage1"] || [[segue identifier] isEqualToString:@"goToCommentPage2"]) {
        UINavigationController *navController = [segue destinationViewController];
        CommentViewController *destViewController = (CommentViewController *)([navController viewControllers][0]);
        destViewController.itemID = self.itemData[@"fields"][@"item_id"];
        destViewController.itemUserID = self.itemData[@"fields"][@"user_id"];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0 || indexPath.section == 2 || indexPath.section == 3) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Set the text color of our header/footer text.
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Set the background color of our header/footer.
    header.contentView.backgroundColor = [self.navigationController.view.tintColor colorWithAlphaComponent:0.5f];
    
    // You can also do this to set the background color of our header/footer,
    //    but the gradients/other effects will be retained.
    // view.tintColor = [UIColor blackColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"self.itemLocationMap.hidden = %hhd", self.itemLocationMap.hidden);
    if (indexPath.section==2 && indexPath.row==0) {
        if (!self.hasComment) {
            self.commentTabelCell.hidden = YES;
            return 0.0;
        } else {
            self.commentTabelCell.hidden = NO;
            
            CGFloat height = self.commentPage.tableView.contentSize.height;
            NSLog(@"height = %f", height);
            CGRect commentPageFrame = self.commentPage.tableView.frame;
            [self.commentPage.tableView setFrame:CGRectMake(0, 0, commentPageFrame.size.width, height)];
            //CGRect commentPageFrame2 = self.commentContainer.frame;
            //[self.commentContainer setFrame:CGRectMake(0, commentPageFrame2.origin.y, commentPageFrame2.size.width, height)];
            
            if (height < self.commentContainer.frame.size.height) {
                height = self.commentContainer.frame.size.height;
            }
            return height + 40;
        }
    } else if (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 2)) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell layoutIfNeeded];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height + 1;
    } else if (indexPath.section==3 && indexPath.row==0 && self.itemLocationMap.hidden) { // Hide Map if neccessary
        return 0.0;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - LPGoogleFunctions

- (LPGoogleFunctions *)googleFunctions
{
    if (!_googleFunctions) {
        _googleFunctions = [LPGoogleFunctions new];
        _googleFunctions.googleAPIBrowserKey = googleAPIBrowserKey;
        _googleFunctions.delegate = self;
        _googleFunctions.sensor = YES;
        _googleFunctions.languageCode = @"en";
    }
    return _googleFunctions;
}
@end
