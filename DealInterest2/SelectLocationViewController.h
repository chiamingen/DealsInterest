//
//  SelectLocationViewController.h
//  DealInterest2
//
//  Created by xiaoming on 31/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPGoogleFunctions.h"

@protocol SelectLocationViewControllerDelegate
- (void)returnFromLocation:(NSString *)location address:(NSString *)address lat:(double)lat lng:(double)lng;
@end

@interface SelectLocationViewController : UIViewController <LPGoogleFunctionsDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) id<SelectLocationViewControllerDelegate> delegate;
@end
