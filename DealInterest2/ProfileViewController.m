//
//  ProfileViewController.m
//  DealInterest2
//
//  Created by xiaoming on 21/6/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "ItemViewController.h"
#import "Helper.h"
#import "FollowTableViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIView *profileDetailsWindow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemListingHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *myListingCollection;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNoOfPosts;
@property (weak, nonatomic) IBOutlet UILabel *userNoOfFollowers;
@property (weak, nonatomic) IBOutlet UILabel *userNoOfFollowings;
@property (weak, nonatomic) IBOutlet UILabel *feedbackPositive;
@property (weak, nonatomic) IBOutlet UILabel *feedbackNeutral;
@property (weak, nonatomic) IBOutlet UILabel *feedbackNegative;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property NSMutableArray *itemData;
@property NSMutableDictionary *userData;
@property NSMutableDictionary *userStats;
@property NSMutableDictionary *userProfile;
@property NSIndexPath *selectedCellIndexPath;
@property NSInteger isFollowing;
@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
 - (IBAction)deleteListedItem:(id)sender {
 // Setup the activity indicator
 MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
 hud.labelText = @"Deleting item";
 
 UIButton *button = (UIButton *) sender;
 
 UICollectionViewCell *cell = (UICollectionViewCell *)[[button superview] superview];
 NSIndexPath *indexPath = [self.myListingCollection indexPathForCell:cell];
 
 // Fetch user ID, device ID, token and item ID
 NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
 NSString * userID = [prefs objectForKey:@"userID"];
 NSString * deviceID = [prefs objectForKey:@"deviceID"];
 NSString * token = [prefs objectForKey:@"token"];
 NSDictionary *item = [self.itemData objectAtIndex:indexPath.row];
 NSString *itemID = item[@"pk"];
 
 // Prepare the delete item URL
 NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/item.deleteItem/"];
 
 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
 NSDictionary *parameters = @{
 @"item_id": itemID,
 @"user_id": userID,
 @"device_id": deviceID,
 @"token": token,
 };
 [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
 // Update the screen
 [self.itemData removeObjectAtIndex:indexPath.row];
 [self.myListingCollection deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
 
 // Hide the activity indicator only if both user listing, stats and profile are loaded
 if (self.itemData && self.userStats && self.userProfile) {
 [MBProgressHUD hideHUDForView:self.view animated:YES];
 }
 } failure:nil];
 }
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Helper drawTopBorder:self.profileDetailsWindow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshProfile:)
                                                 name:@"RefreshProfileNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteItemCell:)
                                                 name:@"DeleteItemNotification"
                                               object:nil];
    [self getProfile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// http://stackoverflow.com/questions/14223931/change-uitableview-height-dynamically
- (void)adjustHeightOfTableview
{
    CGFloat height = self.myListingCollection.collectionViewLayout.collectionViewContentSize.height;
    //NSLog(@"height: %f", height);
    
    // now set the height constraint accordingly
    self.itemListingHeightConstraint.constant = height;
    [self.view needsUpdateConstraints];
}

-(void)deleteItemCell:(NSNotification *)notification {
    NSLog(@"Delete Item Cell");
    self.userNoOfPosts.text = [NSString stringWithFormat:@"%d", ([self.userData[@"item_count"] integerValue] - 1)];
    NSLog(@"No of listing now = %d", ([self.userData[@"item_count"] integerValue] - 1));
    [self.itemData removeObjectAtIndex:self.selectedCellIndexPath.row];
    [self.myListingCollection deleteItemsAtIndexPaths:@[self.selectedCellIndexPath]];
    [self adjustHeightOfTableview];
}

-(void)refreshProfile:(NSNotification *)notification {
    NSLog(@"Refresh Profile");
    [self clearProfile];
    [self getProfile];
}

- (IBAction)followButton:(id)sender {
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Following %@", self.userName.text];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    NSString *deviceID = [prefs objectForKey:@"deviceID"];
    NSString *token = [prefs objectForKey:@"token"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Fetch the category JSON from server
    NSDictionary *parameters = @{
                                 @"user_id": userID,
                                 @"followed_id": self.targetUserID,
                                 @"device_id": deviceID,
                                 @"token": token
                                 };
    NSString *url;
    
    if (self.isFollowing) {
        url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/follow.remove/"];
    } else {
        url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/follow.insert/"];
    }
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if (self.isFollowing) {
            [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
            [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.followButton.backgroundColor = [UIColor greenColor];
        } else {
            [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
            [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.followButton.backgroundColor = [UIColor lightGrayColor];
        }
        
        self.isFollowing = !self.isFollowing;
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
    
}

-(void)getProfile {
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Profile";
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * userID = [prefs objectForKey:@"userID"];
    
    if (!self.targetUserID) {
        NSLog(@"No target user ID");
        self.targetUserID = userID;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }
    // Fetch user ID
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"user_id": userID, @"target_user_id": self.targetUserID};
    
    // Fetch the user listing JSON from server
    [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.getProfilePage/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Profile JSON %@", responseObject);
        
        // All the item that belong to the user
        self.itemData = [responseObject[@"items"] mutableCopy];
        [self.myListingCollection reloadData];
        
        [self adjustHeightOfTableview];
        
        self.userData = [responseObject[@"user"] mutableCopy];
        
        // Config follow button
        if (self.targetUserID != userID) {
            self.followButton.hidden = NO;
            self.isFollowing = [self.userData[@"has_followed"] integerValue];
            if (self.isFollowing) {
                [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
                [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.followButton.backgroundColor = [UIColor lightGrayColor];
            } else {
                [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.followButton.backgroundColor = [UIColor greenColor];
            }
        }
        
        // User stat
        self.userNoOfPosts.text = [NSString stringWithFormat:@"%@", self.userData[@"item_count"]];
        self.userNoOfFollowers.text = [NSString stringWithFormat:@"%@", self.userData[@"follower_count"]];
        self.userNoOfFollowings.text = [NSString stringWithFormat:@"%@", self.userData[@"following_count"]];
        self.userNoOfPosts.hidden = NO;
        self.userNoOfFollowers.hidden = NO;
        self.userNoOfFollowings.hidden = NO;
        
        // User Feedback
        self.feedbackPositive.text = [NSString stringWithFormat:@"%@", self.userData[@"feedback_positive"]];
        self.feedbackNeutral.text = [NSString stringWithFormat:@"%@", self.userData[@"feedback_neutral"]];
        self.feedbackNegative.text = [NSString stringWithFormat:@"%@", self.userData[@"feedback_negative"]];
        self.feedbackPositive.hidden = NO;
        self.feedbackNeutral.hidden = NO;
        self.feedbackNegative.hidden = NO;
        
        // User basic info
        self.userName.text = self.userData[@"user_name"];
        self.userName.hidden = NO;
        
        NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, self.userData[@"profile_pic"]]];
        [self.profileImage setImageWithURL:profilePicUrl placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
        
        [hud hide:YES];
    } failure:nil];

}

-(void)clearProfile {
    self.userNoOfPosts.hidden = YES;
    self.userNoOfFollowers.hidden = YES;
    self.userNoOfFollowings.hidden = YES;
    self.userName.hidden = YES;
    
    self.itemData = [[NSMutableArray alloc] init];
    [self.myListingCollection reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.itemData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MyListingCell";
    
    // Get the cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // Get the activity indicator inside the cell
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:102];
    
    // Extract the item data from array needed for this specific cell
    NSDictionary *item = [self.itemData objectAtIndex:indexPath.row];
    
    // Get the ImageView of this cell
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    
    // Load the image into the cell's ImageView
    NSURL *imgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, item[@"photo1"]]];
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
    [appDelegate showItemScreen:[item[@"id"] integerValue] itemName:item[@"title"] isEditable:YES navController:self.navigationController];
    
}

- (IBAction)follow:(id)sender {

        
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // G
    if ([[segue identifier] isEqualToString:@"goToFollowingPage"])
    {
        FollowTableViewController *destViewController = segue.destinationViewController;
        destViewController.targetUserID = self.targetUserID;
        destViewController.isFollowing = YES;
    } else if ([[segue identifier] isEqualToString:@"goToFollowerPage"])
    {
        FollowTableViewController *destViewController = segue.destinationViewController;
        destViewController.targetUserID = self.targetUserID;
        destViewController.isFollowing = NO;
    }
}
@end
