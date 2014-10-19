//
//  EditProfileTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 14/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "EditProfileTableViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "Helper.h"

@interface EditProfileTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userMobile;
@property (weak, nonatomic) IBOutlet UITextView *userBio;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@property BOOL hasProfilePicChanged;

@end

@implementation EditProfileTableViewController

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
    self.hasProfilePicChanged = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    // Fetch user ID
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * userID = [prefs objectForKey:@"userID"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Fetch the user listing JSON from server
    NSDictionary *parameters = @{@"user_id": userID};
    [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.getUserProfile/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON %@", responseObject);
        
        self.userEmail.text = responseObject[@"email"];
        self.userMobile.text = responseObject[@"hp"];
        self.userBio.text = responseObject[@"profile_description"];
        
        NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, responseObject[@"profile_pic"]]];
        [self.userProfilePic setImageWithURL:profilePicUrl placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}

- (IBAction)tapProfilePic:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:NO completion:^{
        [self displayEditorForImage:chosenImage];
    }];
}

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    // kAviaryAPIKey and kAviarySecret are developer defined
    // and contain your API key and secret respectively
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFPhotoEditorController setAPIKey:kAviaryAPIKey secret:kAviarySecret];
    });
    
    [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
    [AFPhotoEditorCustomization setCropToolInvertEnabled:NO];
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[square]];
    
    //[AFPhotoEditorCustomization setToolOrder:@[kAFCrop]];
    
    
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [editorController setDelegate:self];
    NSLog(@"imageToEdit = %@", imageToEdit);
    NSLog(@"editorController = %@", editorController);
    
    [self presentViewController:editorController animated:NO completion:nil];
}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    // Handle the result image here
    self.userProfilePic.image = image;
    self.hasProfilePicChanged = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    // Handle cancellation here
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton:(id)sender {
    // Dismiss the keyboard
    [self.view endEditing:YES];
    
    if ([self validateForm]) {
        [self uploadProfile];
    }
}

// Return YES if there is no error else return NO
- (BOOL)validateForm {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if ([self.userEmail.text isEqualToString:@""]) {
        [errors addObject:@"Email cannot be blank"];
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

// http://stackoverflow.com/questions/190908/how-can-i-disable-the-uitableview-selection-highlighting
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A case was selected, so push into the CaseDetailViewController
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"didSelectRowAtIndexPath: %@", cell.reuseIdentifier);
    if ([cell.reuseIdentifier isEqualToString:@"emailTableCell"]) {
        [self.userEmail becomeFirstResponder];
    } else if ([cell.reuseIdentifier isEqualToString:@"mobileTableCell"]) {
        [self.userMobile becomeFirstResponder];
    } else if ([cell.reuseIdentifier isEqualToString:@"bioTableCell"]) {
        [self.userBio becomeFirstResponder];
    }
}



-(void)uploadProfile {
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Updating Profile";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * userID = [prefs objectForKey:@"userID"];
    NSString * deviceID = [prefs objectForKey:@"deviceID"];
    NSString * token = [prefs objectForKey:@"token"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{
                                 @"user_id": userID,
                                 @"device_id": deviceID,
                                 @"token": token,
                                 @"hp": self.userMobile.text,
                                 @"profile_description": self.userBio.text,
                                 @"email": self.userEmail.text
    };
    // Fetch the user listing JSON from server
    
    NSLog(@"Para = %@", parameters);
    
    [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.updateProfile2/"] parameters:parameters  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (self.hasProfilePicChanged) {
            NSData *inImage1 = UIImageJPEGRepresentation(self.userProfilePic.image, 0.1);
            [formData appendPartWithFileData:inImage1 name:@"profile_pic" fileName:@"hello1.jpg" mimeType:@"application/octet-stream"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject[@"responseCode"] integerValue] == 1) {
            // Reset
            self.hasProfilePicChanged = NO;
            
            if (responseObject[@"profile_pic"]) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setObject:responseObject[@"profile_pic"] forKey:@"profilePic"];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshProfileNotification" object:self];
            
            [hud hide:YES];
            [Helper showCompletedDialog:self.view];
        } else {
            [hud hide:YES];
            // Display alert message
            [Helper popupAlert:responseObject[@"responseText"]];
        }
    } failure:nil];
}
@end
