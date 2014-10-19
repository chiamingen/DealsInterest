//
//  HomeViewController.m
//  DealInterest2
//
//  Created by xiaoming on 18/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "Helper.h"
#import "AppDelegate.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end

@implementation HomeViewController

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
    
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSString *fbAccessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    NSLog(@"access token = %@", fbAccessToken);
    NSLog(@"fb id = %@", user.objectID);
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSString *fbAccessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    [self registerUser:fbAccessToken];
}

-(void)registerUser:(NSString *)access_token {
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    NSString *deviceID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{
                                 @"access_token": access_token,
                                 @"device_id": deviceID,
                                 };
    // Fetch the user listing JSON from server
    
    NSLog(@"Para = %@", parameters);
    
    [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.fb_register_login/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject[@"responseCode"] integerValue] == 1) {
            NSLog(@"Successful");
            
            [Helper setUserPref:responseObject[@"user"] token:responseObject[@"token"]];
            
            [hud hide:YES];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showMainScreen];
            
            NSLog(@"Facebook Registered and Log In");
        } else {
            [hud hide:YES];
            // Display alert message
            [Helper popupAlert:responseObject[@"responseText"]];
        }
    } failure:nil];
}

@end
