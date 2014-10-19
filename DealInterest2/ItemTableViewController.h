//
//  ItemTableViewController.h
//  DealInterest2
//
//  Created by xiaoming on 24/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemCommentTableViewController.h"
#import "LPGoogleFunctions.h"

@interface ItemTableViewController : UITableViewController <LPGoogleFunctionsDelegate>
@property NSMutableDictionary *itemData;
-(void)loadData;
@end
