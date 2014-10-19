//
//  SearchFilterTableViewController.h
//  DealInterest2
//
//  Created by xiaoming on 6/8/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryViewController.h"

@interface SearchFilterTableViewController : UITableViewController
@property CategoryViewController *delegate;

// For search filter
@property NSInteger sortBy;
@property float priceRangeFrom;
@property float priceRangeTo;
@end
