//
//  ChangePasswordTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 14/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ChangePasswordTableViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "Helper.h"

@interface ChangePasswordTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *currentPassword;
@property (weak, nonatomic) IBOutlet UITextField *theNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *retypePassword;

@end

@implementation ChangePasswordTableViewController

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

// Return YES if there is no error else return NO
- (BOOL)validateForm {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if ([self.currentPassword.text isEqualToString:@""]) {
        [errors addObject:@"Current password cannot be blank"];
    }
    
    if ([self.theNewPassword.text isEqualToString:@""]) {
        [errors addObject:@"New password cannot be blank"];
    }
    
    if ([self.retypePassword.text isEqualToString:@""]) {
        [errors addObject:@"Retype password cannot be blank"];
    }
    
    if (![self.theNewPassword.text isEqualToString:self.retypePassword.text]) {
        [errors addObject:@"New and retype password does not match"];
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

- (IBAction)doneButton:(id)sender {
    if ([self validateForm]) {
        // Setup the activity indicator
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Updating Password";
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString * userID = [prefs objectForKey:@"userID"];
        NSString * deviceID = [prefs objectForKey:@"deviceID"];
        NSString * token = [prefs objectForKey:@"token"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        // Fetch the user listing JSON from server
        NSDictionary *parameters = @{
                                     @"user_id": userID,
                                     @"device_id": deviceID,
                                     @"token": token,
                                     @"oldpassword": self.currentPassword.text,
                                     @"newpassword1": self.theNewPassword.text,
                                     @"newpassword2": self.retypePassword.text
                                     };
        [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.changePassword2/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON %@", responseObject);
            
            [hud hide:YES];
            
            if ([responseObject[@"responseText"] isEqualToString:@"Success!"]) {
                // Dismiss the keyboard
                [self.view endEditing:YES];
                
                [Helper showCompletedDialog:self.view];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password Failed"
                                                                message:responseObject[@"responseText"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                // Display alert message
                [alert show];
            }
        } failure:nil];
    }
}

// http://stackoverflow.com/questions/190908/how-can-i-disable-the-uitableview-selection-highlighting
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A case was selected, so push into the CaseDetailViewController
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([cell.reuseIdentifier isEqualToString:@"currentPasswordTableCell"]) {
        [self.currentPassword becomeFirstResponder];
    } else if ([cell.reuseIdentifier isEqualToString:@"newPasswordTableCell"]) {
        [self.theNewPassword becomeFirstResponder];
    } else if ([cell.reuseIdentifier isEqualToString:@"retypePasswordTableCell"]) {
        [self.retypePassword becomeFirstResponder];
    }
}

@end
