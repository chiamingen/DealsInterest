//
//  CommentViewController.h
//  DealInterest2
//
//  Created by xiaoming on 12/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemTableViewController.h"

@interface CommentViewController : UIViewController <UITextFieldDelegate>
@property NSString *itemID;
@property NSString *itemUserID;
@end
