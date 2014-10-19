//
//  ListOfferViewController.m
//  DealInterest2
//
//  Created by xiaoming on 20/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ListOfferViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "Helper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SellerOfferViewController.h"

@interface ListOfferViewController ()
@property (weak, nonatomic) IBOutlet UITableView *offerTable;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UIImageView *photo1;
@property (weak, nonatomic) IBOutlet UIView *itemWindow;
@property NSMutableArray *offerData;
@property NSIndexPath *currentSelectedIndexPath;
@end

@implementation ListOfferViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRowStatus:) name:@"UpdateRowStatusNotification" object:nil];
    
    [Helper drawBottomBorder:self.itemWindow];
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    
    NSURL *photo1Url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, self.itemData[@"fields"][@"photo1"]]];
    [self.photo1 setImageWithURL:photo1Url];
    self.price.text = [NSString stringWithFormat:@"$%.2f", [self.itemData[@"fields"][@"price"] floatValue]];
    self.itemTitle.text = self.itemData[@"fields"][@"title"];

    NSString *itemID = self.itemData[@"fields"][@"item_id"];
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/deals.list2/"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"item_id": itemID
                                 };
    NSLog(@"%@", parameters);
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        if ([responseObject count] > 0) {
            self.offerData = [responseObject mutableCopy];
        } else {
            self.offerData = [[NSMutableArray alloc] init];
        }
        
        [self.offerTable reloadData];
        
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}

- (void)updateRowStatus:(NSNotification *)notification {
    NSDictionary *data = [notification userInfo];
    
    NSNumber *status = data[@"status"];
    NSMutableDictionary *offer = [self.offerData[self.currentSelectedIndexPath.row] mutableCopy];
    NSMutableDictionary *fields = [offer[@"offer"] mutableCopy];
    fields[@"status"] = status;
    
    offer[@"offer"] = fields;
    self.offerData[self.currentSelectedIndexPath.row] = offer;
    
    [self.offerTable reloadRowsAtIndexPaths:@[self.currentSelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    [self.offerTable deselectRowAtIndexPath:[self.offerTable indexPathForSelectedRow] animated:YES];
    
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath = %ld, %d", (long)[indexPath section], [indexPath row]);
    NSDictionary *offer = [self.offerData objectAtIndex:indexPath.row];
    
    NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, offer[@"buyer"][@"profile_pic"]]];
    UIImageView *image = (UIImageView *)[cell viewWithTag:100];
    image.layer.cornerRadius = 25;
    image.clipsToBounds = YES;
    [image setImageWithURL:profilePicUrl placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
    
    UILabel *buyerName = (UILabel *)[cell viewWithTag:101];
    buyerName.text = offer[@"buyer"][@"name"];
    
    UILabel *offerPrice = (UILabel *)[cell viewWithTag:102];
    offerPrice.text = [NSString stringWithFormat:@"$%.2f", [offer[@"offer"][@"price"] floatValue]];
    
    UILabel *date = (UILabel *)[cell viewWithTag:103];
    date.text = [Helper calculateDate:offer[@"offer"][@"date"]];
    
    if ([offer[@"offer"][@"status"] integerValue] == 1) {
        UILabel *statusLabel = (UILabel *)[cell viewWithTag:104];
        statusLabel.hidden = NO;
    } else if ([offer[@"offer"][@"status"] integerValue] == 2) {
        UILabel *statusLabel = (UILabel *)[cell viewWithTag:105];
        statusLabel.hidden = NO;
    } else if ([offer[@"offer"][@"status"] integerValue] == 3) {
        UILabel *statusLabel = (UILabel *)[cell viewWithTag:106];
        statusLabel.hidden = NO;
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"goToSellerOfferPage"]) {
        // Get the category controller
        SellerOfferViewController *destViewController = segue.destinationViewController;
        
        // Method for getting the indexPath
        // http://www.appcoda.com/ios-collection-view-tutorial/
        NSArray *indexPaths = [self.offerTable indexPathsForSelectedRows];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        self.currentSelectedIndexPath = indexPath;
        
        // Get category data for the selected cell
        NSDictionary *offer = [self.offerData objectAtIndex:indexPath.row];
        
        // Pass the category name to the category controller
        destViewController.otherUserID = offer[@"buyer"][@"id"];
        destViewController.otherUserName = offer[@"buyer"][@"name"];
        destViewController.status = [offer[@"offer"][@"status"] integerValue];
        destViewController.itemID = self.itemData[@"fields"][@"item_id"];
        destViewController.itemName = self.itemData[@"fields"][@"title"];
        destViewController.currentOfferPrice = [offer[@"offer"][@"price"] floatValue];
        destViewController.chatroomID = offer[@"offer"][@"chatroom_id"];
    }
    
}

@end
