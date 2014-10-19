//
//  UploadItemViewController.h
//  DealInterest2
//
//  Created by xiaoming on 26/6/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemCategoryTableTableViewController.h"
#import "ItemDescFieldViewController.h"
#import "ItemDescFieldViewController.h"
#import "SelectLocationViewController.h"
#import <AviarySDK/AviarySDK.h>

@interface UploadItemViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AFPhotoEditorControllerDelegate, ItemCategoryTableTableViewControllerDelegate, ItemDescFieldViewControllerDelegate, SelectLocationViewControllerDelegate>

@property UIImage *imageData;
@property BOOL isEditItem;

@property NSString *itemID;
@property NSString *category;
@property NSString *title;
@property NSString *price;
@property NSString *desc;
@property NSString *photo1;
@property NSString *photo2;
@property NSString *photo3;
@property NSString *photo4;
@property NSString *locationName;
@property NSString *locationAddress;
@property double itemLat;
@property double itemLng;

@end
