//
//  ImagePageViewController.h
//  DealInterest2
//
//  Created by xiaoming on 11/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePageViewController : UIPageViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) NSArray *pageImages;

@end
