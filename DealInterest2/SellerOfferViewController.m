//
//  SellerOfferViewController.m
//  DealInterest2
//
//  Created by xiaoming on 21/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "SellerOfferViewController.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
#import "OfferPriceViewController.h"
#import "OfferChatViewController.h"
#import "FeedbackViewController.h"

@interface SellerOfferViewController ()
@property (weak, nonatomic) IBOutlet UIButton *acceptOfferButton;
@property (weak, nonatomic) IBOutlet UIButton *declineOfferButton;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property OfferChatViewController *offerChatViewController;
@property (weak, nonatomic) IBOutlet UIView *offerWindow;
@property (weak, nonatomic) IBOutlet UIView *pendingDealWindow;
@property (weak, nonatomic) IBOutlet UIView *dealCompleteWindow;
@property (weak, nonatomic) IBOutlet UILabel *currentOfferPriceLabel;
@end

@implementation SellerOfferViewController

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
    
    [Helper drawTopBottomBorder:self.offerWindow];
    [Helper drawTopBottomBorder:self.pendingDealWindow];
    [Helper drawTopBottomBorder:self.dealCompleteWindow];
    
    self.title = [NSString stringWithFormat:@"Buyer: %@", self.otherUserID];
    self.itemNameLabel.text = self.itemName;
    self.currentOfferPriceLabel.text = [NSString stringWithFormat:@"$%.2f", self.currentOfferPrice];
    
    [self configureButton];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveNewMessage:) name:@"ReceiveNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButton:) name:@"AddNewChatNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButton:) name:@"RefreshChatNotification" object:nil];
}

- (void)updateButton:(NSNotification *)notification {
    NSDictionary *data = [notification userInfo];
    if ([self.chatroomID isEqualToString:data[@"chatroom_id"]]) {
        self.status = [data[@"status"] integerValue];
        self.currentOfferPriceLabel.text = [NSString stringWithFormat:@"$%.2f", [data[@"priceOffered"] floatValue]];
        [self configureButton];
    }
}

- (IBAction)goToFeedbackPage:(id)sender {
    // Get login screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"FeedbackPage"];
    FeedbackViewController *viewController = (FeedbackViewController *)([navController viewControllers][0]);
    viewController.itemID = self.itemID;
    viewController.toUserID = self.otherUserID;
    viewController.isSeller = 0;
    [self presentViewController:navController animated:YES completion:nil];
}
- (IBAction)testing:(id)sender {
    self.dealCompleteWindow.hidden = NO;
    self.offerWindow.hidden = YES;
    self.pendingDealWindow.hidden = YES;
}

-(void)configureButton {
    NSLog(@"Config button status = %d", self.status);
    if (self.status == 1) {
        self.pendingDealWindow.hidden = NO;
        self.offerWindow.hidden = YES;
        self.dealCompleteWindow.hidden = YES;
    } else if (self.status == 2) {
        self.offerWindow.hidden = NO;
        self.pendingDealWindow.hidden = YES;
        self.dealCompleteWindow.hidden = YES;
        
        self.acceptOfferButton.enabled = YES;
        self.acceptOfferButton.alpha = 1;
        self.declineOfferButton.enabled = YES;
        self.declineOfferButton.alpha = 1;
    } else if (self.status == 3) {
        self.offerWindow.hidden = NO;
        self.pendingDealWindow.hidden = YES;
        self.dealCompleteWindow.hidden = YES;
        
        self.acceptOfferButton.enabled = YES;
        self.acceptOfferButton.alpha = 1;
        self.declineOfferButton.enabled = NO;
        self.declineOfferButton.alpha = 0.2;
    } else if (self.status == 4) {
        NSLog(@"Deal complete hidding");
        self.dealCompleteWindow.hidden = NO;
        self.offerWindow.hidden = YES;
        self.pendingDealWindow.hidden = YES;
    }
}

- (IBAction)goToItemPage:(id)sender {
    NSLog(@"Go to item Page");
    // Dismiss the keyboard
    [self.view endEditing:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showItemScreen:[self.itemID integerValue] itemName:self.itemName isEditable:NO navController:self.navigationController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"goToChatPage"]) {
        OfferChatViewController *destViewController = [segue destinationViewController];
        destViewController.itemID = self.itemID;
        destViewController.chatroomID = self.chatroomID;
        destViewController.role = @"seller";
        self.offerChatViewController = destViewController;
    }

}
- (IBAction)itemSold:(id)sender {
    [self updateStatus:4];
}

- (IBAction)acceptOffer:(id)sender {
    [self updateStatus:1];
}

- (IBAction)declineOffer:(id)sender {
    [self updateStatus:3];
}


-(void)updateStatus:(NSInteger)status {
// Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    // Setup the URL for fetching the JSON from the server which contain all the item for this category
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/deals.setStatus2/"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"chatroom_id": self.chatroomID,
                                 @"status": @(status)
                                 };
    NSLog(@"%@", parameters);
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"%@", responseObject);
        // Update status
        self.status = status;
        [self configureButton];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *profilePic = [prefs objectForKey:@"profilePic"];
        NSString *userID = [prefs objectForKey:@"userID"];
        NSString *username = [prefs objectForKey:@"username"];
        
        NSMutableDictionary *userInfo = [@{@"senderID":userID, @"senderName": username, @"profilePic": profilePic, @"chatroom_id": self.chatroomID} mutableCopy];
        if (self.status == 3) {
            userInfo[@"message"] = @"Offer Declined";
        } else if (self.status == 1) {
            userInfo[@"message"] = @"Offer Accepted";
        } else if (self.status == 4) {
            userInfo[@"message"] = @"Deal Completed";
        }
     
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddNewChatNotification" object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateRowStatusNotification" object:nil userInfo:@{@"status": @(status)}];
        
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}
@end
