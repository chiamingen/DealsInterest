//
//  ItemCategoryTableTableViewController.h
//  DealInterest2
//
//  Created by xiaoming on 27/6/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemCategoryTableTableViewController;

@protocol ItemCategoryTableTableViewControllerDelegate
- (void)returnFromCategoryTable:(NSString *) category;
@end

@interface ItemCategoryTableTableViewController : UITableViewController
@property (weak, nonatomic) id<ItemCategoryTableTableViewControllerDelegate> delegate;
@end

