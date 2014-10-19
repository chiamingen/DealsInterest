//
//  ItemDescFieldViewController.h
//  DealInterest2
//
//  Created by xiaoming on 10/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemDescFieldViewControllerDelegate
- (void)returnFromDescField:(NSString *) description;
@end

@interface ItemDescFieldViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) id<ItemDescFieldViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property NSString *description;
@end