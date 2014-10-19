//
//  ImagePageContentViewController.h
//  DealInterest2
//
//  Created by xiaoming on 11/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@end
