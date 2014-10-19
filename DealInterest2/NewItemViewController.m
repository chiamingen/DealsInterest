//
//  NewItemViewController.m
//  DealInterest2
//
//  Created by xiaoming on 24/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "NewItemViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "ItemTableViewController.h"
#import "ListOfferViewController.h"
#import "BuyerOfferViewController.h"
#import "UploadItemViewController.h"
#import "JBWhatsAppActivity.h"
#import "LINEActivity.h"

@interface NewItemViewController ()
@property ItemTableViewController *itemPage;
@property NSMutableDictionary *itemData;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *priceToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *buyerToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *sellerToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sellerToobarText;
@property (weak, nonatomic) IBOutlet UIButton *sellerToolbarButton;

@end

@implementation NewItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)share:(id)sender {
    
    // http://nshipster.com/uiactivityviewcontroller/
    NSArray *activityItems;
    //NSString *message = [NSString stringWithFormat:@"Checkout this item at DealInterest: %@ - %@", self.itemData[@"fields"][@"title"], self.itemData[@"fields"][@"description"]];
    NSString *message = [NSString stringWithFormat:@"Checkout this item at DealInterest: %@", self.itemData[@"fields"][@"title"]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@item/%@", ServerBaseUrl, self.itemData[@"pk"]]];
    
    
    WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc] initWithMessage:[NSString stringWithFormat:@"Checkout this item at DealInterest: %@ %@", self.itemData[@"fields"][@"title"], url] forABID:nil];
    
    activityItems = @[message, url, whatsappMsg];
    
    NSArray *applicationActivities = @[[[JBWhatsAppActivity alloc] init], [[LINEActivity alloc] init]];
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems
     applicationActivities:applicationActivities];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList];
    
    activityController.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Do any additional setup after loading the view.
    if (self.itemEditable) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Edit"
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(editItem)];
        self.navigationItem.rightBarButtonItem = editButton;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshItemDetails:)
                                                 name:@"RefreshItemDetailsNotification"
                                               object:nil];
    [self getItemDetails];
}

- (void)refreshItemDetails:(NSNotification *)notification {
    NSLog(@"refreshItemDetails");
    [self getItemDetails];
}

-(void)getItemDetails {
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Item";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
        
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    // Prepare the category JSON URL
    NSString *itemUrl = [NSString stringWithFormat:@"%@json/browse.getItemInfo2/", ServerBaseUrl];


    NSDictionary *parameters = @{
                             @"item_id": @(self.itemID),
                             @"user_id": userID
                             };
    
    // Fetch the category JSON from server
    [manager POST:itemUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.itemPage.itemData = [[responseObject objectAtIndex:0] mutableCopy];
        NSLog(@"responseObject = %@", responseObject);
        [self.itemPage loadData];
        
        self.itemData = self.itemPage.itemData;
        
        self.title = self.itemData[@"fields"][@"title"];
        
        self.priceToolbar.title = [NSString stringWithFormat:@"$%.2f", [self.itemData[@"fields"][@"price"] floatValue]];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSInteger userID = [[prefs objectForKey:@"userID"] integerValue];
        if (userID == [self.itemData[@"fields"][@"user_id"] integerValue]) {
            self.sellerToolbar.hidden = NO;
            if ([self.itemData[@"num_of_offer"] integerValue] > 0) {
                self.sellerToobarText.title = [NSString stringWithFormat:@"You have %@ offers", self.itemData[@"num_of_offer"]];
            } else {
                self.sellerToobarText.title = @"You have no offer yet";
                self.sellerToolbarButton.hidden = YES;
            }
        } else {
            self.buyerToolbar.hidden = NO;
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    } failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToItemViewPage"])
    {
        ItemTableViewController *destViewController = segue.destinationViewController;
        self.itemPage = destViewController;
    } else if ([[segue identifier] isEqualToString:@"goToBuyerOfferPage"]) {
        // Get the category controller
        BuyerOfferViewController *destViewController = segue.destinationViewController;
        destViewController.itemID = self.itemData[@"pk"];
        destViewController.itemName = self.itemData[@"fields"][@"title"];
        destViewController.otherUserID = self.itemData[@"fields"][@"user_id"];
        destViewController.otherUserName = self.itemData[@"fields"][@"user_name"];
        destViewController.defaultPrice = [self.itemData[@"fields"][@"price"] floatValue];
        destViewController.status = [self.itemData[@"buyer_offer_status"] integerValue];
        destViewController.currentOfferPrice = [self.itemData[@"current_user_offer"] floatValue];
        
        // Calculate chatroom ID
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *userID = [prefs objectForKey:@"userID"];
        destViewController.chatroomID = [NSString stringWithFormat:@"i%@b%@s%@", destViewController.itemID, userID, destViewController.otherUserID];
    } else if ([[segue identifier] isEqualToString:@"goToListOfferPage"]) {
        // Get the category controller
        ListOfferViewController *destViewController = segue.destinationViewController;
        destViewController.itemData = self.itemData;
    }
}

- (IBAction)clickProfile:(id)sender {
    // Show login screen
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showOthersProfileScreen:YES otherUserID:self.itemData[@"fields"][@"user_id"] navController:self.navigationController];
}



-(IBAction)editItem {
    //NSLog(@"Edit Item");
    // Get others profile screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UploadItemViewController *viewController = (UploadItemViewController *)[storyboard instantiateViewControllerWithIdentifier:@"itemFormScreen"];
    viewController.isEditItem = YES;
    
    viewController.itemID = self.itemData[@"pk"];
    viewController.category = self.itemData[@"fields"][@"category"];
    viewController.title = self.itemData[@"fields"][@"title"];
    viewController.price = [NSString stringWithFormat:@"$%.2f", [self.itemData[@"fields"][@"price"] floatValue]];
    viewController.desc = self.itemData[@"fields"][@"description"];
    viewController.photo1 = self.itemData[@"fields"][@"photo1"];
    viewController.photo2 = self.itemData[@"fields"][@"photo2"];
    viewController.photo3 = self.itemData[@"fields"][@"photo3"];
    viewController.photo4 = self.itemData[@"fields"][@"photo4"];
    viewController.locationName = self.itemData[@"fields"][@"location_name"];
    viewController.locationAddress = self.itemData[@"fields"][@"location_address"];
    viewController.itemLat = [self.itemData[@"fields"][@"lat"] doubleValue];
    viewController.itemLng = [self.itemData[@"fields"][@"lng"] doubleValue];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
