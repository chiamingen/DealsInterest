//
//  SysInfoTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 20/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "SysInfoTableViewController.h"

@interface SysInfoTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *deviceIDField;
@property (weak, nonatomic) IBOutlet UITextField *tokenField;

@end

@implementation SysInfoTableViewController

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
    
    NSString *deviceID = [prefs objectForKey:@"deviceID"];
    NSString *token = [prefs objectForKey:@"token"];
    
    NSLog(@"Device ID = %@", deviceID);
    NSLog(@"Token = %@", token);
    
    self.deviceIDField.text = deviceID;
    self.tokenField.text = token;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
