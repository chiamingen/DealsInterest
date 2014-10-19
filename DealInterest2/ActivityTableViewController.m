//
//  ActivityTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 22/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ActivityTableViewController.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
#import <SVPullToRefresh.h>

@interface ActivityTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *activityTable;
@property NSMutableArray *activityData;
@property UIRefreshControl *refreshControl;
@property NSInteger currentPage;
@end

@implementation ActivityTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.currentPage = 1;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"ViewDidLoad = Activity Controller View");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshActivity:)
                                                 name:@"RefreshActivityNotification"
                                               object:nil];
    
    __weak ActivityTableViewController *tmpSelf= self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        // prepend data to dataSource, insert cells at top of table view
        // call [tableView.pullToRefreshView stopAnimating] when done
        [tmpSelf getActivity:YES infiniteScroll:NO];
    }];
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        // append data to data source, insert new cells at the end of table view
        // call [tableView.infiniteScrollingView stopAnimating] when done
        [tmpSelf getActivity:NO infiniteScroll:YES];
    }];
    [self getActivity:NO infiniteScroll:NO];
}

-(void)refreshActivity:(NSNotification *)notification {
    NSLog(@"Refresh Activity List");
    self.activityData = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    [self getActivity:NO infiniteScroll:NO];
}

-(void)getActivity:(BOOL)isPullToRefresh infiniteScroll:(BOOL)infiniteScroll {
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
    [manager.requestSerializer setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    NSDictionary *parameters = @{@"user_id": userID, @"page": @(self.currentPage)};
    NSLog(@"parameters = %@", parameters);
    NSString *url = [NSString stringWithFormat:@"%@json/user.activity/", ServerBaseUrl];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Get JSON: %@", responseObject);
        
        if ([responseObject[@"is_last_row"] intValue]) {
            self.tableView.showsInfiniteScrolling = NO;
        }
        
        if (isPullToRefresh) {
            self.activityData = [responseObject[@"activity"] mutableCopy];
            [self.tableView.pullToRefreshView stopAnimating];
        } else if (infiniteScroll) {
            [self.activityData addObjectsFromArray:[responseObject[@"activity"] mutableCopy]];
            [self.tableView.infiniteScrollingView stopAnimating];
        } else {
            self.activityData = [responseObject[@"activity"] mutableCopy];
            [hud hide:YES];
        }
        
        [self.tableView reloadData];
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (isPullToRefresh) {
            [self.tableView.pullToRefreshView stopAnimating];
        } else if (infiniteScroll) {
            [self.tableView.infiniteScrollingView stopAnimating];
        } else {
            [hud hide:YES];
        }
        
        NSLog(@"Error: %@", error);
        [Helper popupAlert:[NSString stringWithFormat:@"%@", error]];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.activityData count];
}

// http://useyourloaf.com/blog/2014/02/14/table-view-cells-with-varying-row-heights.html
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self configureCell:tableView forRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        return [self configureCell:tableView forRowAtIndexPath:indexPath];
}

- (UITableViewCell *)configureCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath = %ld, %d", (long)[indexPath section], [indexPath row]);
    NSDictionary *activity = [self.activityData objectAtIndex:indexPath.row];
    
    UITableViewCell *cell;
    NSMutableAttributedString *content;
    if ([activity[@"type"] isEqualToString:@"follow"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FollowTableCell"];
        content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ started following you", activity[@"from_user_name"]]];
    } else if ([activity[@"type"] isEqualToString:@"message"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MessageTableCell"];
        content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ sent you a message: %@", activity[@"from_user_name"], activity[@"activity"]]];
        UIImageView *image = (UIImageView *)[cell viewWithTag:104];
        NSURL *itemPhotoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, activity[@"item_photo"]]];
        [image setImageWithURL:itemPhotoURL placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
    } else if ([activity[@"type"] isEqualToString:@"offer"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"OfferTableCell"];
        content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", activity[@"from_user_name"], activity[@"activity"]]];
        UIImageView *image = (UIImageView *)[cell viewWithTag:104];
        NSURL *itemPhotoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, activity[@"item_photo"]]];
        [image setImageWithURL:itemPhotoURL placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
    }
    
    NSURL *fromUserProfilePic = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, activity[@"from_user_profile_pic"]]];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:100];
    [image setImageWithURL:fromUserProfilePic placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
    
    UITextView *words = (UITextView *)[cell viewWithTag:101];
    [content addAttribute:NSForegroundColorAttributeName value:self.navigationController.view.tintColor range:NSMakeRange(0, [activity[@"from_user_name"] length])];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:14] range:NSMakeRange(0, [content length])];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-bold" size:14] range:NSMakeRange(0, [activity[@"from_user_name"] length])];
    words.attributedText = content;
    //[words sizeToFit];
    
    UILabel *date = (UILabel *)[cell viewWithTag:102];
    date.text = [Helper calculateDate:activity[@"timestamp"]];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
