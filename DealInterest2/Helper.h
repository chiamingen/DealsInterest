//
//  Helper.h
//  DealInterest2
//
//  Created by xiaoming on 12/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject
+ (NSString *) calculateDate:(NSString *)itemDate;
+ (void) popupAlert:(NSString *) text;
+ (void) showCompletedDialog:(UIView *)view;
+ (void) setUserPref:(NSDictionary *)loginData token:(NSString *)token;
+ (void) adjustTextFieldForPrice:(UITextField *) priceTextBox;
+ (void) drawTopBottomBorder:(UIView *)view;
+(void) drawTopBorder:(UIView *)view;
+(void) drawBottomBorder:(UIView *)view;
@end
