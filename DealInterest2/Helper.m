//
//  Helper.m
//  DealInterest2
//
//  Created by xiaoming on 12/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "Helper.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@implementation Helper

+ (NSString *) calculateDate:(NSString *)itemDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Singapore"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // User last activity date
    NSDate *date = [dateFormatter dateFromString:itemDate];
    
    //NSLog(@"Date: %@", date);
    
    // Current date
    NSDate *now = [NSDate date];
    // Find difference in days
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:date toDate:now options:0];
    // NSLog(@"Date difference: %@",difference);
    if([difference day] >= 31){
        long numOfMonths = (long)[difference day]/31;
        if (numOfMonths >= 12){
            long numOfYears = numOfMonths/12;
            return [NSString stringWithFormat:@"%ld years ago",numOfYears];
        } else {
            return [NSString stringWithFormat:@"%ld months ago",numOfMonths];
        }
    } else {
        if ([difference day] > 0) {
            return [NSString stringWithFormat:@"%ld days ago",(long)[difference day]];
        } else {
            return [NSString stringWithFormat:@"Today"];
        }
    }
}

+ (void) popupAlert:(NSString *) text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void) showCompletedDialog:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Completed";
    
    [hud show:YES];
    [hud hide:YES afterDelay:1.25];
}

+ (void) setUserPref:(NSDictionary *)user token:(NSString *)token {
    NSLog(@"setUserPref");
    NSLog(@"user = %@", user);
    NSLog(@"token = %@", token);
    
    NSString *deviceID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:user[@"user_id"] forKey:@"userID"];
    [prefs setObject:token forKey:@"token"];
    [prefs setObject:user[@"user_name"] forKey:@"username"];
    [prefs setObject:user[@"profile_pic"] forKey:@"profilePic"];
    [prefs setObject:user[@"email"] forKey:@"email"];
    [prefs setObject:deviceID forKey:@"deviceID"];
    [prefs setBool:YES forKey:@"loggedIn"];
    [prefs synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshProfileNotification" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshActivityNotification" object:self];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Update server with the latest chat token
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updatePushToken];
}

+ (void) adjustTextFieldForPrice:(UITextField *) priceTextBox {
    // Convert string to nsmutablestring first
    NSMutableString *ms = [NSMutableString stringWithString:priceTextBox.text];
    // Remove all decimal points in string
    ms = [[ms stringByReplacingOccurrencesOfString:@"." withString:@""] mutableCopy];
    // Remove all commas in string
    ms = [[ms stringByReplacingOccurrencesOfString:@"," withString:@""] mutableCopy];
    // Remove all dollar sign in string
    ms = [[ms stringByReplacingOccurrencesOfString:@"$" withString:@""] mutableCopy];
    if([ms hasPrefix:@"0"]){
        priceTextBox.text = [ms substringFromIndex:1];
        // Convert string to nsmutablestring first
        ms = [NSMutableString stringWithString:priceTextBox.text];
        // Remove all decimal points in string
        ms = [[ms stringByReplacingOccurrencesOfString:@"." withString:@""] mutableCopy];
        // Remove all commas in string
        ms = [[ms stringByReplacingOccurrencesOfString:@"," withString:@""] mutableCopy];
        // Remove all dollar sign in string
        ms = [[ms stringByReplacingOccurrencesOfString:@"$" withString:@""] mutableCopy];
        //NSLog(@"Modified string: %@",ms);
    }
    
    /*
     int dollarLength = 0;
     if([ms length] >= 6){
     dollarLength = [ms length] - 2;
     while(dollarLength > 0){
     if(dollarLength != [ms length] - 2){
     [ms insertString:@"," atIndex:dollarLength];
     }
     dollarLength = dollarLength - 3;
     }
     }
     */
    if([ms length] > 2){
        [ms insertString:@"." atIndex:[ms length]-2];
    }
    if([ms length] == 1){
        [ms insertString:@"0.0" atIndex:0];
    }
    if([ms length] == 2){
        [ms insertString:@"0." atIndex:0];
    }
    
    if(![ms hasPrefix:@"$"]){
        priceTextBox.text = [NSString stringWithFormat:@"$%@",ms];
    }
}

+(void) drawTopBottomBorder:(UIView *)view {
    // Add a bottomBorder.
    // http://stackoverflow.com/questions/7666863/uiview-bottom-border
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, view.frame.size.height -1, view.frame.size.width, 1.0f);
    
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    
    [view.layer addSublayer:bottomBorder];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, view.frame.size.width, 1.0f);
    
    topBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                  alpha:1.0f].CGColor;
    
    [view.layer addSublayer:topBorder];
}

+(void) drawTopBorder:(UIView *)view {
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, view.frame.size.width, 1.0f);
    
    topBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                  alpha:1.0f].CGColor;
    
    [view.layer addSublayer:topBorder];
}

+(void) drawBottomBorder:(UIView *)view {
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, view.frame.size.height, view.frame.size.width, 1.0f);
    
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    
    [view.layer addSublayer:bottomBorder];
}
@end
