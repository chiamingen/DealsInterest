//
//  OfferPriceViewController.m
//  DealInterest2
//
//  Created by xiaoming on 20/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "OfferPriceViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "Helper.h"

@interface OfferPriceViewController ()
@property (weak, nonatomic) IBOutlet UITextField *priceOffer;

@end

@implementation OfferPriceViewController

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
    //[self.priceOffer becomeFirstResponder];
    self.priceOffer.text = [NSString stringWithFormat:@"$%.2f", self.defaultPrice];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)submit:(id)sender {
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sending Offer";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSString *userID = [prefs objectForKey:@"userID"];
    NSString *deviceID = [prefs objectForKey:@"deviceID"];
    NSString *token = [prefs objectForKey:@"token"];
    
    // Remove dollar sign
    NSRange range = NSMakeRange(0,1);
    NSString *price = [self.priceOffer.text stringByReplacingCharactersInRange:range withString:@""];
    
    // Setup the URL for fetching the JSON from the server which contain all the item for this category
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/deals.offer2/"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"user_id": userID,
                                 @"chatroom_id": self.chatroomID,
                                 @"item_id": self.itemID,
                                 @"price_offered": price,
                                 @"device_id": deviceID,
                                 @"token": token
                                 };
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *userID = [prefs objectForKey:@"userID"];
        NSString *profilePic = [prefs objectForKey:@"profilePic"];
        NSString *username = [prefs objectForKey:@"username"];

        NSDictionary *userInfo = @{@"priceOffered": price, @"senderID": userID, @"senderName": username, @"message": [NSString stringWithFormat:@"I have a new offer to you! ($%@)", price], @"profilePic": profilePic, @"chatroom_id": self.chatroomID};
        NSLog(@"userInfo = %@", userInfo);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddNewChatNotification" object:nil userInfo:userInfo];
        
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
                [self dismissViewControllerAnimated:YES completion:nil];
    } failure:nil];
}

- (IBAction)closePage:(id)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)priceChanged:(id)sender {
    UITextField *priceTextBox = (UITextField *)sender;
    [Helper adjustTextFieldForPrice:priceTextBox];
}

@end
