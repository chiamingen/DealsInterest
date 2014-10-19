//
//  OfferViewController.m
//  DealInterest2
//
//  Created by xiaoming on 19/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "BuyerOfferViewController.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
#import "OfferPriceViewController.h"
#import "OfferChatViewController.h"
#import "FeedbackViewController.h"

@interface BuyerOfferViewController ()
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UIView *offerWindow;
@property (weak, nonatomic) IBOutlet UIView *dealCompleteWindow;
@property (weak, nonatomic) IBOutlet UIView *pendingDealWindow;
@property OfferChatViewController *offerChatViewController;
@property (weak, nonatomic) IBOutlet UILabel *currentOfferPriceLabel;
@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;
@end

@implementation BuyerOfferViewController

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
    
    self.title = [NSString stringWithFormat:@"Seller: %@", self.otherUserName];
    self.itemNameLabel.text = self.itemName;
    self.currentOfferPriceLabel.text = [NSString stringWithFormat:@"$%.2f", self.currentOfferPrice];
    
    [self configureButton];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveNewMessage:) name:@"ReceiveNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButton:) name:@"AddNewChatNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButton:) name:@"RefreshChatNotification" object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Start out working with the test environment! When you are ready, switch to PayPalEnvironmentProduction.
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
}

- (void)updateButton:(NSNotification *)notification {
    NSDictionary *data = [notification userInfo];
    if ([self.chatroomID isEqualToString:data[@"chatroom_id"]]) {
        self.status = [data[@"status"] integerValue];
        self.currentOfferPrice = [data[@"priceOffered"] floatValue];
        self.currentOfferPriceLabel.text = [NSString stringWithFormat:@"$%.2f", self.currentOfferPrice];
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
    viewController.isSeller = 1;
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)configureButton {
    if (self.status == 1) {
        self.pendingDealWindow.hidden = NO;
        self.offerWindow.hidden = YES;
        self.dealCompleteWindow.hidden = YES;
    } else if (self.status == 2) {
        self.offerWindow.hidden = NO;
        self.pendingDealWindow.hidden = YES;
        self.dealCompleteWindow.hidden = YES;
    } else if (self.status == 3) {
        self.offerWindow.hidden = NO;
        self.pendingDealWindow.hidden = YES;
        self.dealCompleteWindow.hidden = YES;
    } else if (self.status == 4) {
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
    NSLog(@"Here = %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"goToChatPage"]) {
        OfferChatViewController *destViewController = [segue destinationViewController];
        destViewController.itemID = self.itemID;
        destViewController.chatroomID = self.chatroomID;
        destViewController.role = @"buyer";
        self.offerChatViewController = destViewController;
    } else if ([[segue identifier] isEqualToString:@"goToOfferPricePage"]) {
            UINavigationController *navController = [segue destinationViewController];
            OfferPriceViewController *destViewController = (OfferPriceViewController *)([navController viewControllers][0]);
            destViewController.chatroomID = self.chatroomID;
            destViewController.itemID = self.itemID;
            destViewController.defaultPrice = self.defaultPrice;
    }
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _payPalConfiguration = [[PayPalConfiguration alloc] init];
        
        // See PayPalConfiguration.h for details and default values.
        // Should you wish to change any of the values, you can do so here.
        // For example, if you wish to accept PayPal but not payment card payments, then add:
        _payPalConfiguration.acceptCreditCards = YES;
        // Or if you wish to have the user choose a Shipping Address from those already
        // associated with the user's PayPal account, then add:
        _payPalConfiguration.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    }
    return self;
}

- (IBAction)pay {
    
    // Create a PayPalPayment
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    
    // Amount, currency, and description
    payment.amount = [[NSDecimalNumber alloc] initWithFloat:self.currentOfferPrice];
    payment.currencyCode = @"SGD";
    payment.shortDescription = self.itemName;
    
    // Use the intent property to indicate that this is a "sale" payment,
    // meaning combined Authorization + Capture. To perform Authorization only,
    // and defer Capture to your server, use PayPalPaymentIntentAuthorize.
    payment.intent = PayPalPaymentIntentSale;
    
    // If your app collects Shipping Address information from the customer,
    // or already stores that information on your server, you may provide it here.
    // payment.shippingAddress = address; // a previously-created PayPalShippingAddress object
    
    // Check whether payment is processable.
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
        NSLog(@"Error in payment");
    } else {
        
        // Create a PayPalPaymentViewController.
        PayPalPaymentViewController *paymentViewController;
        paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                       configuration:self.payPalConfiguration
                                                                            delegate:self];
        
        // Present the PayPalPaymentViewController.
        [self presentViewController:paymentViewController animated:YES completion:nil];
    }
}

#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    // Send the entire confirmation dictionary
    //NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
   //                                                        options:0
    //                                                         error:nil];
    NSDictionary *confirmation = completedPayment.confirmation;
    
    NSLog(@"confirmation = %@", completedPayment.confirmation);
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sending Payment";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    NSDictionary *parameters = @{
                                 @"user_id": userID,
                                 @"item_id": self.itemID,
                                 @"code": confirmation[@"response"][@"id"],
                                 @"amount": @(self.currentOfferPrice)
                                 };
    NSLog(@"parameters = %@", parameters);
    
    [manager POST:[NSString stringWithFormat:@"%@json/payment.insert/", ServerBaseUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud setHidden:YES];
    } failure:nil];
}

@end
