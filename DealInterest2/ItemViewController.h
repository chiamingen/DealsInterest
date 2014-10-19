//
//  ItemViewController.h
//  DealInterest2
//
//  Created by xiaoming on 26/5/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property NSInteger itemID;
@property NSString *itemName;
@property BOOL itemEditable;
@end
