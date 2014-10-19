//
//  CustomInfoWindow.h
//  DealInterest2
//
//  Created by xiaoming on 1/8/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomInfoWindow : UIView
@property (weak, nonatomic) IBOutlet UILabel* itemName;
@property (weak, nonatomic) IBOutlet UIImageView *itemPhoto;
@property (weak, nonatomic) IBOutlet UILabel* itemPrice;
@end
