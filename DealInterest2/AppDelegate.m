//
//  AppDelegate.m
//  DealInterest2
//
//  Created by xiaoming on 22/5/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "AppDelegate.h"
#import "../LoginTableViewController.h"
#import "ProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "SellerOfferViewController.h"
#import "BuyerOfferViewController.h"
#import "NewItemViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "PayPalMobile.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GMSServices provideAPIKey:googleAPIIOSKey];
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor whiteColor];
    //[self.window makeKeyAndVisible];
    //[FBLoginView class];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox : @"AcPiPBC-R2ssFJhm-uZmGNVlPWEAJuo36vD0jUvtK-SUCzcvr_q5h-X5jlcK"}];
    
    // http://stackoverflow.com/questions/19962276/best-practices-for-storyboard-login-screen-handling-clearing-of-data-upon-logou
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // Show login view if not logged in already
    if([prefs objectForKey:@"loggedIn"]) {
        [self showMainScreen];
    } else {
        [self showLoginScreen:NO];
    }
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString* newDeviceToken = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
	NSLog(@"My chat token is: %@", newDeviceToken);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs objectForKey:@"loggedIn"]) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:newDeviceToken forKey:@"pushToken"];
        [prefs synchronize];
        // Update user chat token on server
        [self updatePushToken];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
    NSDictionary *data = userInfo[@"data"];
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navcon = (UINavigationController*)tabBarController.selectedViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([data[@"message_for"] isEqualToString:@"seller"]) {
        // Do not push if the chat view controller is already at the top of the screen
        if (![navcon.topViewController isKindOfClass:[SellerOfferViewController class]]) {
            // Get login screen from storyboard and present it
            SellerOfferViewController *viewController = (SellerOfferViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SellerOfferPage"];
            viewController.otherUserID = data[@"senderID"];
            viewController.otherUserName = data[@"senderName"];
            viewController.status = [data[@"status"] integerValue];
            viewController.itemID = data[@"itemID"];
            viewController.itemName = data[@"itemName"];
            viewController.currentOfferPrice = [data[@"priceOffered"] floatValue];
            viewController.chatroomID = data[@"chatroom_id"];
            self.tmpViewController  = viewController;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You receive a new message"
                                                            message:data[@"message"]
                                                           delegate:self
                                                  cancelButtonTitle:@"View"
                                                  otherButtonTitles:@"Cancel", nil];
            [alert show];
        }
        
    } else if ([data[@"message_for"] isEqualToString:@"buyer"]) {
        // Do not push if the chat view controller is already at the top of the screen
        if (![navcon.topViewController isKindOfClass:[BuyerOfferViewController class]]) {
            BuyerOfferViewController *viewController = (BuyerOfferViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BuyerOfferPage"];
            viewController.otherUserID = data[@"senderID"];
            viewController.otherUserName = data[@"senderName"];
            viewController.status = [data[@"status"] integerValue];
            viewController.itemID = data[@"itemID"];
            viewController.itemName = data[@"itemName"];
            viewController.currentOfferPrice = [data[@"priceOffered"] floatValue];
            viewController.chatroomID = data[@"chatroom_id"];
            self.tmpViewController  = viewController;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You receive a new message"
                                                            message:data[@"message"]
                                                           delegate:self
                                                  cancelButtonTitle:@"View"
                                                  otherButtonTitles:@"Cancel", nil];
            [alert show];
        }
    }
    
    
    
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"Coming from inside");
        // Only add the message directly if the chat window is already at the top of the view and the application is currently active
        if ([navcon.topViewController isKindOfClass:[BuyerOfferViewController class]] || [navcon.topViewController isKindOfClass:[SellerOfferViewController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddNewChatNotification" object:nil userInfo:data];
        }
    } else {
        // Get the chat from the server if you are coming from lock screen, home screen or when the top view controller is not the chat window
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshChatNotification" object:nil];
        NSLog(@"Coming from outside");
    }
    
    NSLog(@"Class = %@", [navcon.topViewController class]);
    //[navcon pushViewController:viewController animated:YES];
    //[self.window makeKeyAndVisible];
    //[self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index =%ld",(long)buttonIndex);
    if (buttonIndex == 0)
    {
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        UINavigationController *navcon = (UINavigationController*)tabBarController.selectedViewController;
        [navcon pushViewController:self.tmpViewController animated:NO];
    }
    self.tmpViewController = nil;
}

-(void)updatePushToken {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * userID = [prefs objectForKey:@"userID"];
    NSString * deviceID = [prefs objectForKey:@"deviceID"];
    NSString * token = [prefs objectForKey:@"token"];
    NSString *deviceToken = [prefs objectForKey:@"pushToken"];
    
    NSLog(@"Update chat token on server for user id = %@", userID);
    
    if (deviceToken) {
        NSDictionary *parameters = @{
                                     @"user_id": userID,
                                     @"device_id": deviceID,
                                     @"token": token,
                                     @"device_type": @"ios",
                                     @"chat_token": deviceToken
                                     };
        
        [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/registerIOSPushToken/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON %@", responseObject);
         } failure:nil];
    } else {
        NSLog(@"No chat token to update");
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

-(void) showLoginScreen:(BOOL)animated
{
    /*
    // Get login screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginTableViewController *viewController = (LoginTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginBetaScreen"];
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:viewController
                                                 animated:animated
                                               completion:nil];
     */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginTableViewController *viewController = (LoginTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginBetaScreen"];
    self.window.rootViewController = viewController;
}

-(void) showMainScreen
{
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
}

-(void) showOthersProfileScreen:(BOOL)animated otherUserID:(NSString *)otherUserID navController:(UINavigationController *)navController
{
    // Get others profile screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *viewController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfilePage"];
    viewController.targetUserID = otherUserID;
    
    [navController pushViewController:viewController animated:YES];
    
    //[self.window makeKeyAndVisible];
    //[self.window.rootViewController presentViewController:viewController animated:animated completion:nil];
}

-(void) showItemScreen:(NSInteger)itemID itemName:(NSString *)itemName isEditable:(BOOL)isEditable navController:(UINavigationController *)navController
{
    // Get others profile screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewItemViewController *viewController = (NewItemViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NewItemViewPage"];
    viewController.itemID = itemID;
    viewController.itemName = itemName;
    viewController.itemEditable = isEditable;
    
    [navController pushViewController:viewController animated:YES];
}

-(void) showItemScreen2:(NSInteger)itemID itemName:(NSString *)itemName isEditable:(BOOL)isEditable navController:(UINavigationController *)navController
{
    // Get others profile screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewItemViewController *viewController = (NewItemViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NewItemViewPage"];
    viewController.itemID = itemID;
    viewController.itemName = itemName;
    viewController.itemEditable = isEditable;
    
    [navController pushViewController:viewController animated:YES];
}

-(void) showHomeScreen:(BOOL)animated
{
    // Get login screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginTableViewController *viewController = (LoginTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:viewController
                                                 animated:animated
                                               completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
