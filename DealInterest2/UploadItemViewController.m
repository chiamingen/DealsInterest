//
//  UploadItemViewController.m
//  DealInterest2
//
//  Created by xiaoming on 26/6/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "UploadItemViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Helper.h"

@interface UploadItemViewController ()

@property (weak, nonatomic) IBOutlet UITextField *itemCategory;
@property (weak, nonatomic) IBOutlet UITextField *itemTitle;
@property (weak, nonatomic) IBOutlet UITextField *itemPrice;
@property (weak, nonatomic) IBOutlet UITextView *itemDesc;
@property (weak, nonatomic) IBOutlet UIImageView *itemPhoto1;
@property (weak, nonatomic) IBOutlet UIImageView *itemPhoto2;
@property (weak, nonatomic) IBOutlet UITextField *itemLocationName;
@property (weak, nonatomic) IBOutlet UITextField *itemLocationAddress;
@property NSString * itemPriceWithoutDollarSign;
@property (weak, nonatomic) IBOutlet UIButton *deleteListingButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navBarLeftButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navBarRightButton;
@property BOOL isDescFieldEmpty;

// Below property all for photo function
@property UIImageView *activeUIImageView;
@property NSInteger activePhotoNumber;
@property BOOL hasNewPhoto1;
@property BOOL hasNewPhoto2;

@property UIImagePickerController *picker;
@property BOOL photoTakingInProgress;
@property (nonatomic) NSInteger flashMode;

@end

@implementation UploadItemViewController

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
    // self.imageView.image = self.imageData;
    self.activeUIImageView = self.itemPhoto1;
    self.photoTakingInProgress = NO;
    self.activePhotoNumber = 1;
    self.hasNewPhoto1 = NO;
    self.hasNewPhoto2 = NO;
    self.itemLat = 0.0;
    self.itemLng = 0.0;
    
    if (!self.isEditItem) {
        self.hasNewPhoto1 = YES; // Add new item definately have new photo in first slot
        self.isDescFieldEmpty = YES;
    }
    
    if (self.isEditItem) {
        self.deleteListingButton.hidden = NO;
        
        self.itemCategory.text = self.category;
        self.itemTitle.text = self.title;
        self.itemPrice.text = self.price;
        if ([self.desc length] > 0) {
            self.itemDesc.textColor = [UIColor blackColor];
        }
        self.itemDesc.text = self.desc;
        // Load the 1st photo
        NSURL *photo1Url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, self.photo1]];
        [self.itemPhoto1 setImageWithURL:photo1Url];
        
        NSURL *photo2Url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, self.photo2]];
        [self.itemPhoto2 setImageWithURL:photo2Url];
        
        self.navBarLeftButton.title = @"Back";
        self.title = [NSString stringWithFormat:@"Edit %@", self.title];
        
        self.itemLocationName.text = self.locationName;
        self.itemLocationAddress.text = self.locationAddress;
    } else {
        self.deleteListingButton.hidden = YES;
        self.navBarLeftButton.title = @"Cancel";
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.itemPhoto1.image == nil && !self.isEditItem && !self.photoTakingInProgress) {
        NSLog(@"viewDidAppear showcam");
        [self showCamera];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)photo1ImageVIew:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select photo option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Retake Photo",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)photo2ImageView:(id)sender {
    // If image already exists show the retake and delete action sheet popup
    if (self.itemPhoto2.image) {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select photo option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Retake Photo",
                                @"Delete Photo",
                                nil];
        popup.tag = 2;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    } else {
        self.activePhotoNumber = 2;
        self.activeUIImageView = self.itemPhoto2;
        [self showCamera];
    }
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    NSLog(@"Retake Photo");
                    self.activePhotoNumber = 1;
                    self.activeUIImageView = self.itemPhoto1;
                    [self showCamera];
                    break;
                default:
                    break;
            }
            break;
        }
        case 2: {
            switch (buttonIndex) {
                case 0:
                    NSLog(@"Retake Photo");
                    self.activePhotoNumber = 2;
                    self.activeUIImageView = self.itemPhoto2;
                    [self showCamera];
                    break;
                case 1:
                    NSLog(@"Delete Photo");
                    self.itemPhoto2.image = nil;
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[self performSegueWithIdentifier:@"goToMainMenu" sender:nil];
    // Get login screen from storyboard and present it
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //LoginTableViewController *viewController = (LoginTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    //[self presentViewController:viewController animated:NO completion:nil];
    NSLog(@"delete");
    
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
        self.photoTakingInProgress = NO;
        [self.tabBarController setSelectedIndex:0];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
         [self.picker dismissViewControllerAnimated:NO completion:nil];
    }
}


#pragma mark - Navigation

- (void)returnFromDescField:(NSString *)description {
    if ([description length] > 0) {
        self.itemDesc.textColor = [UIColor blackColor];
        self.itemDesc.text = description;
        self.isDescFieldEmpty = NO;
    } else {
        [self setPlaceholder];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)returnFromLocation:(NSString *)name address:(NSString *)address lat:(double)lat lng:(double)lng {
    self.itemLocationName.text = name;
    self.itemLocationAddress.text = address;
    self.itemLat = lat;
    self.itemLng = lng;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setPlaceholder {
    // http://stackoverflow.com/questions/9218755/what-does-70-grey-mean-and-how-do-i-specify-this-in-uicolor
    UIColor* grey80 = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.itemDesc.textColor = grey80;
    self.itemDesc.text = @"Item Description (Required)\nExample: Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et";
    self.isDescFieldEmpty = YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"goToItemCategoryScreen"])
    {
        ItemCategoryTableTableViewController *con = [segue destinationViewController];
        con.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"goToItemDescFieldScreen"]) {
        ItemDescFieldViewController *con = [segue destinationViewController];
        if (!self.isDescFieldEmpty) {
            con.description = self.itemDesc.text;
        }
        con.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"goToItemLocationScreen"])
    {
        SelectLocationViewController *con = [segue destinationViewController];
        con.delegate = self;
    }
}

-(void)showCamera {
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    
    self.picker.showsCameraControls = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *UI = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"cameraView"];
    self.picker.cameraOverlayView  = UI.view;
    
    UIButton *captureButton = (UIButton *)[UI.view viewWithTag:101];
    [captureButton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = (UIButton *)[UI.view viewWithTag:102];
    [cancelButton addTarget:self action:@selector(cancelPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *openLibButton = (UIButton *)[UI.view viewWithTag:103];
    [openLibButton addTarget:self action:@selector(openPhotoLib:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *flashButton = (UIButton *)[UI.view viewWithTag:104];
    [flashButton addTarget:self action:@selector(toggleFlash:) forControlEvents:UIControlEventTouchUpInside];

    CGRect f = self.picker.view.bounds;
    NSLog(@"width = %f, height = %f", f.size.width, f.size.height);
    
    self.photoTakingInProgress = YES;
    [self presentViewController:self.picker animated:YES completion:NULL];
}

// http://adrianhoe.com/adrianhoe/2014/04/06/cropping-an-uiimage-using-cgimagecreateimageinrect/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage;
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
         chosenImage = info[UIImagePickerControllerOriginalImage];
        
        CGFloat imageWidth  = chosenImage.size.width;
        
        CGRect cropRect;
        cropRect = CGRectMake (430.98, 0, imageWidth, imageWidth);
        
        // Draw new image in current graphics context
        CGImageRef imageRef = CGImageCreateWithImageInRect ([chosenImage CGImage], cropRect);
        
        // Create new cropped UIImage
        UIImage * croppedImage = [UIImage imageWithCGImage: imageRef scale: chosenImage.scale orientation: chosenImage.imageOrientation];
        
        CGImageRelease (imageRef);
        
        chosenImage = croppedImage;
        
        
        [self displayEditorForImage:chosenImage];
    } else {
         chosenImage = info[UIImagePickerControllerEditedImage];
        [self.picker dismissViewControllerAnimated:NO completion:^{
            [self displayEditorForImage:chosenImage];
        }];
        
    }
    //self.imageView.image = chosenImage;
    switch (self.activePhotoNumber) {
        case 1:
            self.hasNewPhoto1 = YES;
            break;
        case 2:
            self.hasNewPhoto2 = YES;
            break;
        default:
            break;
    }
}

// http://stackoverflow.com/questions/22457097/ios-7-1-imagepicker-cameraflashmode-not-indicating-flash-state
- (IBAction)toggleFlash:(UIButton *)sender {
    UIView *view = self.picker.cameraOverlayView;
        UILabel *flashLabel = (UILabel *)[view viewWithTag:105];
    
    if (_flashMode == UIImagePickerControllerCameraFlashModeAuto)
    {
        _flashMode = UIImagePickerControllerCameraFlashModeOff;
        flashLabel.text = @"Off";
    }
    else if (_flashMode == UIImagePickerControllerCameraFlashModeOff)
    {
        _flashMode = UIImagePickerControllerCameraFlashModeOn;
        flashLabel.text = @"On";
    }
    else if (_flashMode == UIImagePickerControllerCameraFlashModeOn)
    {
        _flashMode = UIImagePickerControllerCameraFlashModeAuto;
        flashLabel.text = @"Auto";
    }
    
    self.picker.cameraFlashMode = (UIImagePickerControllerCameraFlashMode)_flashMode;
}

- (IBAction)capturePhoto:(UIButton *)sender {
    [self.picker takePicture];
}

- (IBAction)cancelPhoto:(UIButton *)sender {
    self.photoTakingInProgress = NO;
    [self.tabBarController setSelectedIndex:0];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)openPhotoLib:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self.picker presentViewController:imagePickerController animated:YES completion:nil];
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
    
    [self.picker presentViewController:editorController animated:NO completion:nil];
}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    // Handle the result image here
    
    self.activeUIImageView.image = image;
    self.photoTakingInProgress = NO;
    
    [self.picker dismissViewControllerAnimated:NO completion:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self.picker dismissViewControllerAnimated:YES completion:nil];
}

// http://stackoverflow.com/questions/13110123/prepareforsegue-and-popviewcontroller-compatibility
- (void)returnFromCategoryTable:(NSString *) category {
    self.itemCategory.text = category;
    [self.navigationController popViewControllerAnimated:YES];
}


// http://stackoverflow.com/questions/190908/how-can-i-disable-the-uitableview-selection-highlighting
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A case was selected, so push into the CaseDetailViewController
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"didSelectRowAtIndexPath: %@", cell.reuseIdentifier);
    if ([cell.reuseIdentifier isEqualToString:@"titleTableCell"]) {
        [self.itemTitle becomeFirstResponder];
    } else if ([cell.reuseIdentifier isEqualToString:@"priceTableCell"]) {
        [self.itemPrice becomeFirstResponder];
    } else if ([cell.reuseIdentifier isEqualToString:@"descTableCell"]) {
        [self.itemDesc becomeFirstResponder];
    }
}

- (IBAction)priceChanged:(id)sender {
    UITextField *priceTextBox = (UITextField *)sender;
    [Helper adjustTextFieldForPrice:priceTextBox];
}

- (IBAction)cancelItem:(id)sender {
    if (self.isEditItem) {
        //[self.navigationController popToRootViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self clearUploadForm];
        [self.tabBarController setSelectedIndex:0];
    }
}

- (IBAction)submitItem:(id)sender {
    // Dismiss the keyboard
    [self.view endEditing:YES];
    
    if ([self validateForm]) {
         [self uploadPhoto];
        /*
        if (self.isEditItem) {
            //[self uploaditem:self.photo1];
        } else {
            [self uploadPhoto];
        }
         */
    }
}

- (void)uploadPhoto {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString * userID = [prefs objectForKey:@"userID"];
        NSString * deviceID = [prefs objectForKey:@"deviceID"];
        NSString * token = [prefs objectForKey:@"token"];
        
        // Setup the activity indicator
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Uploading Photo";
        
        
        NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/image.uploadImageMultiple/"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"user_id": userID, @"device_id": deviceID, @"token": token, @"upload_type": @"2"};
        [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (self.hasNewPhoto1) {
                 NSData *inImage1 = UIImageJPEGRepresentation(self.itemPhoto1.image, 0.1);
                [formData appendPartWithFileData:inImage1 name:@"image1" fileName:@"hello1.jpg" mimeType:@"application/octet-stream"];
            }
            if (self.hasNewPhoto2) {
                NSData *inImage2 = UIImageJPEGRepresentation(self.itemPhoto2.image, 0.1);
                [formData appendPartWithFileData:inImage2 name:@"image2" fileName:@"hello2.jpg" mimeType:@"application/octet-stream"];
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSString *photo1Url = responseObject[@"image1_url"];
            NSString *photo2Url = responseObject[@"image2_url"];
            
            if (self.isEditItem) {
                if ([photo1Url isEqualToString:@""]) { // if we didn't upload new image for photo slot 1, it will return empty string
                    if (self.itemPhoto1.image) { // if photo slot 1 still got image, it means that nothing have change. Else if it is nil, it means user have delete the image.
                        photo1Url = self.photo1; // use back old URL;
                    }
                }
                
                if ([photo2Url isEqualToString:@""]) {
                    if (self.itemPhoto2.image) {
                        photo2Url = self.photo2;
                    }
                }
            }
            
            [self uploaditem:photo1Url photo2Url:photo2Url];
        } failure:nil];
}

-(void)uploaditem:(NSString *)photo1Url photo2Url:(NSString *)photo2Url {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * userID = [prefs objectForKey:@"userID"];
    NSString * deviceID = [prefs objectForKey:@"deviceID"];
    NSString * token = [prefs objectForKey:@"token"];
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Uploading Item";
    
    NSLog(@"Submit Item");
    NSLog(@"Item ID: %@", self.itemID);
    NSLog(@"User ID: %@", userID);
    NSLog(@"Device ID: %@", deviceID);
    NSLog(@"Token: %@", token);
    NSLog(@"Category: %@", self.itemCategory.text);
    NSLog(@"Title: %@", self.itemTitle.text);
    NSLog(@"Price: %@", self.itemPrice.text);
    NSLog(@"Photo 1 Url: %@", photo1Url);
    NSLog(@"Photo 2 Url: %@", photo2Url);
    NSLog(@"Description: %@", self.itemDesc.text);
    NSLog(@"Location Name: %@", self.itemLocationName.text);
    NSLog(@"Location Address: %@", self.itemLocationAddress.text);
    NSLog(@"lat: %f", self.itemLat);
    NSLog(@"lng: %f", self.itemLng);

    
    // Remove dollar sign
    NSRange range = NSMakeRange(0,1);
    NSString *price = [self.itemPrice.text stringByReplacingCharactersInRange:range withString:@""];
    
    NSString *url;
    NSDictionary *parameters;
    
    if (self.isEditItem ) {
        url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/item.updateItem/"];
        parameters = @{@"item_id": self.itemID, @"user_id": userID, @"device_id": deviceID, @"token": token, @"title": self.itemTitle.text, @"price": price, @"description": self.itemDesc.text, @"category": self.itemCategory.text, @"photo1": photo1Url, @"photo2": photo2Url, @"location_name": self.itemLocationName.text, @"location_address": self.itemLocationAddress.text, @"lat": @(self.itemLat), @"lng": @(self.itemLng) };
    } else {
        url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/post.insert/"];
        parameters = @{@"user_id": userID, @"device_id": deviceID, @"token": token, @"title": self.itemTitle.text, @"price": price, @"description": self.itemDesc.text, @"category": self.itemCategory.text, @"photo1": photo1Url, @"photo2": photo2Url, @"location_name": self.itemLocationName.text, @"location_address": self.itemLocationAddress.text, @"lat": @(self.itemLat), @"lng": @(self.itemLng) };
    }
    
    NSLog(@"parameters = %@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self clearUploadForm];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (self.isEditItem ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshItemDetailsNotification" object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshProfileNotification" object:self];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshProfileNotification" object:self];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                  message:@"Upload Another Item?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Yes"
                                                        otherButtonTitles:@"No", nil];
            alert.tag = 1;
            // Display alert message
            [alert show];
        }
    } failure:nil];
}

-(void) clearUploadForm {
    self.itemPhoto1.image = nil;
    self.itemCategory.text = nil;
    self.itemTitle.text = nil;
    self.itemPrice.text = nil;
    //self.itemDesc.text = nil;
    
    // reset back to default which is the first photo slot
    self.activePhotoNumber = 1;
    self.activeUIImageView = self.itemPhoto1;
    
    // No more new photo
    self.hasNewPhoto1 = NO;
    self.hasNewPhoto2 = NO;
    
    // clear all photo slot
    self.itemPhoto1.image = nil;
    self.itemPhoto2.image = nil;
    
    [self setPlaceholder];
}

// Return YES if there is no error else return NO
- (BOOL)validateForm {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if ([self.itemCategory.text isEqualToString:@""]) {
        [errors addObject:@"Category cannot be blank"];
    }
    
    if ([self.itemTitle.text isEqualToString:@""]) {
        [errors addObject:@"Title cannot be blank"];
    }
    
    if (self.isDescFieldEmpty) {
        [errors addObject:@"Description cannot be blank"];
    }
    
    // Need to fix
    if ([self.itemPrice.text isEqualToString:@""]) {
        [errors addObject:@"Price cannot be blank"];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1: // For "Upload Another Item?"
            if (buttonIndex == 0) {
                NSLog(@"user pressed Yes");
                [self showCamera];
            } else {
                NSLog(@"user pressed No");
                [self.tabBarController setSelectedIndex:0];
            }
            break;
        case 2: // For "Are you sure? Delete Item
            if (buttonIndex == 0) {
                NSLog(@"user pressed Yes");
                [self deleteItem];
            } else {
                NSLog(@"user pressed No");
            }
            break;
        default:
            break;
    }
}


-(void) deleteItem {
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Deleting item";
    
    
    // Fetch user ID, device ID, token and item ID
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * userID = [prefs objectForKey:@"userID"];
    NSString * deviceID = [prefs objectForKey:@"deviceID"];
    NSString * token = [prefs objectForKey:@"token"];
    
    // Prepare the delete item URL
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/item.deleteItem/"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"item_id": self.itemID,
                                 @"user_id": userID,
                                 @"device_id": deviceID,
                                 @"token": token,
                                 };
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Update the screen
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteItemNotification" object:self];
        
        // Go back to profile page which is at the root of the nagivation controller
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (self.isEditItem) {
        if (indexPath.section == 3) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
        }
    }
    return cell;
}


- (IBAction)deleteListing:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                    message:@"Are you sure?"
                                                   delegate:self
                                          cancelButtonTitle:@"Yes"
                                          otherButtonTitles:@"No", nil];
    alert.tag = 2;
    [alert show];
}

@end
