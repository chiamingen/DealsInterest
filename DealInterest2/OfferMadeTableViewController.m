//
//  OfferMadeTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 31/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "OfferMadeTableViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "Helper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BuyerOfferViewController.h"

@interface OfferMadeTableViewController ()
@property NSMutableArray *offerData;
@property NSIndexPath *currentSelectedIndexPath;
@end

@implementation OfferMadeTableViewController

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
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *userID = [prefs objectForKey:@"userID"];
    
    // Setup the URL for fetching the JSON from the server which contain all the item for this category
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/deals.offerIMade/"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"user_id": userID,
                                 };
    NSLog(@"%@", parameters);
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        if ([responseObject count] > 0) {
            self.offerData = [responseObject mutableCopy];
        } else {
            self.offerData = [[NSMutableArray alloc] init];
        }
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
    return [self.offerData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OfferTableCell"];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath = %ld, %d", (long)[indexPath section], [indexPath row]);
    NSDictionary *offer = [self.offerData objectAtIndex:indexPath.row];
    
    NSURL *itemPicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, offer[@"photo1"]]];
    UIImageView *image = (UIImageView *)[cell viewWithTag:101];
    image.layer.cornerRadius = 5;
    image.clipsToBounds = YES;
    [image setImageWithURL:itemPicUrl];
    
    UILabel *itemName = (UILabel *)[cell viewWithTag:102];
    itemName.text = offer[@"item_name"];
    
    UILabel *listedPrice = (UILabel *)[cell viewWithTag:103];
    listedPrice.text = [NSString stringWithFormat:@"$%.2f", [offer[@"price"] floatValue]];
    
    UILabel *offerPrice = (UILabel *)[cell viewWithTag:104];
    offerPrice.text = [NSString stringWithFormat:@"$%.2f", [offer[@"price_offered"] floatValue]];
    
    UILabel *date = (UILabel *)[cell viewWithTag:105];
    date.text = [Helper calculateDate:offer[@"offered_date"]];
    
    if ([offer[@"status"] integerValue] == 1) {
        UILabel *statusLabel = (UILabel *)[cell viewWithTag:106];
        statusLabel.hidden = NO;
    } else if ([offer[@"status"] integerValue] == 2) {
        UILabel *statusLabel = (UILabel *)[cell viewWithTag:107];
        statusLabel.hidden = NO;
    } else if ([offer[@"status"] integerValue] == 3) {
        UILabel *statusLabel = (UILabel *)[cell viewWithTag:108];
        statusLabel.hidden = NO;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"goToBuyerOfferPage"]) {
        // Get the category controller
        BuyerOfferViewController *destViewController = segue.destinationViewController;
        
        // Method for getting the indexPath
        // http://www.appcoda.com/ios-collection-view-tutorial/
        NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        self.currentSelectedIndexPath = indexPath;
        
        // Get category data for the selected cell
        NSDictionary *offer = [self.offerData objectAtIndex:indexPath.row];
        
        destViewController.itemID = offer[@"item_id"];
        destViewController.itemName = offer[@"item_name"];
        destViewController.otherUserID = offer[@"item_owner_id"];
        destViewController.otherUserName = offer[@"seller_name"];
        destViewController.defaultPrice = [offer[@"price"] floatValue];
        destViewController.status = [offer[@"status"] integerValue];
        destViewController.currentOfferPrice = [offer[@"price_offered"] floatValue];
        destViewController.chatroomID = offer[@"chatroom_id"];
    }
    
}

@end
