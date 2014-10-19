//
//  OfferViewController.h
//  DealInterest2
//
//  Created by xiaoming on 19/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyerOfferViewController.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
#import "OfferPriceViewController.h"
#import "OfferChatViewController.h"
#import "PayPalMobile.h"

@interface BuyerOfferViewController : UIViewController <UITextFieldDelegate, PayPalPaymentDelegate>

@property NSString *itemID;
@property NSString *itemName;
@property NSString *otherUserID;
@property NSString *otherUserName;
@property float defaultPrice;
@property NSInteger status;
@property float currentOfferPrice;
@property NSString *chatroomID;
@end
