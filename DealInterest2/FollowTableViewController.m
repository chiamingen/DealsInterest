//
//  FollowTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 4/8/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "FollowTableViewController.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"

@interface FollowTableViewController ()
@property NSMutableArray *followData;
@end

@implementation FollowTableViewController

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
    
    self.followData = [[NSMutableArray alloc] init];
    
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    NSString *url;
    if (self.isFollowing) {
        url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.following/"];
        self.title = @"Following";
    } else {
        url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.follower/"];
        self.title = @"Follower";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSLog(@"self.targetUserID = %@", self.targetUserID);
    NSDictionary *parameters = @{
                                 @"user_id": userID,
                                 @"target_user_id": self.targetUserID
                                 };
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        self.followData = [responseObject mutableCopy];
        [self.tableView reloadData];
        
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// http://stackoverflow.com/questions/6216839/how-to-add-spacing-between-uitableviewcell
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Number of rows is the number of time zones in the region for the specified section.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.followData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowTableCell"];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath = %ld, %d", (long)[indexPath section], [indexPath row]);
    NSDictionary *follow = [self.followData objectAtIndex:indexPath.row];
    NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, follow[@"profile_pic"]]];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:101];
    image.layer.cornerRadius = image.frame.size.width/2;
    image.clipsToBounds = YES;
    [image setImageWithURL:profilePicUrl placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
    
    UILabel *name = (UILabel *)[cell viewWithTag:102];
    name.text = follow[@"name"];
    
    UIButton *followButton = (UIButton *)[cell viewWithTag:103];
    [followButton addTarget:self action:@selector(followClick:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    if ([follow[@"followed"] integerValue]) {
        [followButton setTitle:@"Following" forState:UIControlStateNormal];
        [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        followButton.backgroundColor = [UIColor lightGrayColor];
    } else {
        [followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        followButton.backgroundColor = [UIColor greenColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

//http://stackoverflow.com/questions/929964/get-section-number-and-row-number-on-custom-cells-button-click
- (void) followClick: (id) sender withEvent: (UIEvent *) event
{
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: location];
    
    NSMutableDictionary *follow = [[self.followData objectAtIndex:indexPath.row] mutableCopy];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    NSString *deviceID = [prefs objectForKey:@"deviceID"];
    NSString *token = [prefs objectForKey:@"token"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Fetch the category JSON from server
    NSDictionary *parameters = @{
                                 @"user_id": userID,
                                 @"followed_id": follow[@"user_id"],
                                 @"device_id": deviceID,
                                 @"token": token
                                 };
    NSString *url;
    
    if ([follow[@"followed"] integerValue]) {
        url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/follow.remove/"];
    } else {
        url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/follow.insert/"];
    }
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if ([follow[@"followed"] integerValue]) {
            follow[@"followed"] = @0;
        } else {
            follow[@"followed"] = @1;
        }
     
        [self.followData replaceObjectAtIndex:indexPath.row withObject:follow];
        [self.tableView reloadData];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
    
    //NSLog(@"[cell class] = %@, Row = %d, User %@ clicked", [cell class], indexPath.row, follow[@"name"]);
}
@end
