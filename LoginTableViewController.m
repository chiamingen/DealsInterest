//
//  LoginTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 20/6/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "LoginTableViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "Helper.h"
#import "AppDelegate.h"

@interface LoginTableViewController ()
- (IBAction)done:(id)sender;
- (void) login;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;

@end

@implementation LoginTableViewController

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.userEmail) {
		[textField resignFirstResponder];
		[self.userPassword becomeFirstResponder];
	} else if (textField == self.userPassword) {
        [self login];
    }
	return NO;
}

- (IBAction)done:(id)sender {
    [self login];
}

- (void) login {
    // Dismiss the keyboard
    [self.view endEditing:YES];
    
    
    if ([self validateForm]) {
        // Setup the activity indicator
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Logging In";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *deviceID = [UIDevice currentDevice].identifierForVendor.UUIDString;
        NSDictionary *parameters = @{
                                     @"email": self.userEmail.text,
                                     @"password": self.userPassword.text,
                                     @"device_id": deviceID
                                     };
        
        [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.login2/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON %@", responseObject);
            
            NSLog(@"%@", responseObject);
            if ([responseObject[@"responseCode"] integerValue] == 1) {
                NSLog(@"Successful Logged In");
                
                [Helper setUserPref:responseObject[@"user"] token:responseObject[@"token"]];
                
                // Update server with the latest chat token
                [hud hide:YES];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate showMainScreen];
                //[self dismissViewControllerAnimated:YES completion:nil];
                NSLog(@"Log In");
            } else {
                [hud hide:YES];
                [Helper popupAlert:responseObject[@"responseText"]];
            }
        } failure:nil];
    }

}

// Return YES if there is no error else return NO
- (BOOL)validateForm {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if ([self.userEmail.text isEqualToString:@""]) {
        [errors addObject:@"Email cannot be blank"];
    }
    
    if ([self.userPassword.text isEqualToString:@""]) {
        [errors addObject:@"Password cannot be blank"];
    }
    
    if ([errors count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Item Failed"
                                                        message:[errors componentsJoinedByString:@"\n"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        // Display alert message
        [alert show];
        return NO;
    } else {
        return YES;
    }
}

@end
