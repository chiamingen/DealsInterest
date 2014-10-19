//
//  OthersProfileViewController.m
//  DealInterest2
//
//  Created by xiaoming on 7/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "OthersProfileViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "ItemViewController.h"

@interface OthersProfileViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *myListingCollection;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNoOfPosts;
@property (weak, nonatomic) IBOutlet UILabel *userNoOfFollowers;
@property (weak, nonatomic) IBOutlet UILabel *userNoOfFollowings;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemListingHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property NSMutableArray *itemData;
@property NSMutableDictionary *userStats;
@property NSMutableDictionary *userProfile;
@property BOOL isFollowing;
@end

@implementation OthersProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
                                 @"followed_id": self.otherUserID,
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
            self.followButton.backgroundColor = [UIColor redColor];
        }
        
        self.isFollowing = !self.isFollowing;
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];

}

-(void)getProfile {
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Fetch the user listing JSON from server
    NSDictionary *parameters = @{@"user_id": self.otherUserID, @"check_has_follow_by_user_id": userID};
    [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.getProfilePage/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"viewDidAppear JSON %@", responseObject);
        
        // All the item that belong to the user
        self.itemData = [responseObject[@"items"] mutableCopy];
        [self.myListingCollection reloadData];
        
        [self adjustHeightOfTableview];
        
        // User stat
        self.userNoOfPosts.text = [NSString stringWithFormat:@"%@", responseObject[@"user"][@"item_count"]];
        self.userNoOfFollowers.text = [NSString stringWithFormat:@"%@", responseObject[@"user"][@"follower_count"]];
        self.userNoOfFollowings.text = [NSString stringWithFormat:@"%@", responseObject[@"user"][@"following_count"]];
        self.userNoOfPosts.hidden = NO;
        self.userNoOfFollowers.hidden = NO;
        self.userNoOfFollowings.hidden = NO;
        
        // User basic info
        self.userName.text = responseObject[@"user"][@"user_name"];
        self.userName.hidden = NO;
        
        NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, responseObject[@"user"][@"profile_pic"]]];
        [self.profileImage setImageWithURL:profilePicUrl placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
        
        // Configure follow button
        if ([responseObject[@"user"][@"has_followed"] integerValue] == 1) {
            self.isFollowing = YES;
            [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
            [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.followButton.backgroundColor = [UIColor redColor];
        } else {
            self.isFollowing = NO;
            [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
            [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.followButton.backgroundColor = [UIColor blueColor];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    NSLog(@"height: %f", height);
    
    // now set the height constraint accordingly
    self.itemListingHeightConstraint.constant = height;
    [self.view needsUpdateConstraints];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Get the category controller
    ItemViewController *destViewController = segue.destinationViewController;
    
    // Method for getting the indexPath
    // http://www.appcoda.com/ios-collection-view-tutorial/
    NSArray *indexPaths = [self.myListingCollection indexPathsForSelectedItems];
    NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
    
    // Get category data for the selected cell
    NSDictionary *item = [self.itemData objectAtIndex:indexPath.row];
    
    // Pass the item id to the category controller
    destViewController.itemID = [item[@"pk"] integerValue];
    
    // Pass the item name to the category controller
    destViewController.itemName = item[@"fields"][@"title"];
    
    // Hide bottom tab bar in the detail view
    destViewController.hidesBottomBarWhenPushed = YES;
}

@end
