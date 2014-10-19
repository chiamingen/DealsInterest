//
//  TestViewController.h
//  DealInterest2
//
//  Created by xiaoming on 4/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryViewController : UIViewController <UISearchBarDelegate>
@property NSString *categoryName;
@property NSString *function;

// For search filter
@property NSInteger sortBy;
@property float priceRangeFrom;
@property float priceRangeTo;
@end
