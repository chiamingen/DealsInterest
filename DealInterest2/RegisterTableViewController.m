//
//  RegisterTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 17/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "RegisterTableViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "Helper.h"
#import "AppDelegate.h"

@interface RegisterTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@end

@implementation RegisterTableViewController

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

// http://stackoverflow.com/questions/190908/how-can-i-disable-the-uitableview-selection-highlighting
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A case was selected, so push into the CaseDetailViewController
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([cell.reuseIdentifier isEqualToString:@"emailTableCell"]) {
        [self.userEmail becomeFirstResponder];
    } else if ([cell.reuseIdentifier isEqualToString:@"usernameTableCell"]) {
        [self.userName becomeFirstResponder];
    } else if ([cell.reuseIdentifier isEqualToString:@"passwordTableCell"]) {
        [self.userPassword becomeFirstResponder];
    }
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
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    // Handle cancellation here
    [self dismissViewControllerAnimated:NO completion:nil];
}

// Return YES if there is no error else return NO
- (BOOL)validateForm {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if ([self.userEmail.text isEqualToString:@""]) {
        [errors addObject:@"Email cannot be blank"];
    }
    
    if ([self.userName.text isEqualToString:@""]) {
        [errors addObject:@"Username cannot be blank"];
    }
    
    if ([self.userEmail.text isEqualToString:@""]) {
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

- (IBAction)doneButton:(id)sender {
    // Dismiss the keyboard
    [self.view endEditing:YES];
    
    if ([self validateForm]) {
        [self registerUser];
    }
}

-(void)registerUser {
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Registering";
    
    NSString *deviceID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{
                                 @"email": self.userEmail.text,
                                 @"username": self.userName.text,
                                 @"password": self.userPassword.text,
                                 @"device_id": deviceID
                                 };
    // Fetch the user listing JSON from server
    
    NSLog(@"Para = %@", parameters);
    
    [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/user.insert2/"] parameters:parameters  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (self.userProfilePic.image) {
            NSData *inImage1 = UIImageJPEGRepresentation(self.userProfilePic.image, 0.1);
            [formData appendPartWithFileData:inImage1 name:@"profile_pic" fileName:@"hello1.jpg" mimeType:@"application/octet-stream"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"%@", responseObject);
        if ([responseObject[@"responseCode"] integerValue] == 1) {
            NSLog(@"Successful");
            
            [Helper setUserPref:responseObject[@"user"] token:responseObject[@"token"]];
            
            [hud hide:YES];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showMainScreen];
            
            NSLog(@"Email Registered and Log In");
        } else {
            [hud hide:YES];
            // Display alert message
            [Helper popupAlert:responseObject[@"responseText"]];
        }
    } failure:nil];
}
@end
