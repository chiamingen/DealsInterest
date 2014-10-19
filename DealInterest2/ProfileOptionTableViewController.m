//
//  ProfileOptionTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 7/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ProfileOptionTableViewController.h"
#import "CategoryViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ProfileOptionTableViewController ()

@end

@implementation ProfileOptionTableViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender {
    NSLog(@"Logout");
    
    // Reset tab controller to first tab so that when user login later they will be at first tab not at profile tab.
    [self.tabBarController setSelectedIndex:0];
    
    // Clear all user data
    // http://stackoverflow.com/questions/545091/clearing-nsuserdefaults
    NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    
    // Clear Facebook session
    [FBSession.activeSession closeAndClearTokenInformation];
    
    // Show login screen
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoginScreen:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"goToStuffILikedPage"])
    {
        
        // Get the category controller
        CategoryViewController *destViewController = segue.destinationViewController;
        
        // Pass the category name to the category controller
        destViewController.function = @"StuffILiked";
    }
}

@end
