//
//  PayPalProfileSharingViewController.h
//
//  Version 2.2.0
//
//  Copyright (c) 2014, PayPal
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalConfiguration.h"
#import "PayPalOAuthScopes.h"

@class PayPalProfileSharingViewController;

#pragma mark - PayPalProfileSharingDelegate

/// Exactly one of these delegate methods will get called when the UI completes.
/// You MUST dismiss the modal view controller from these delegate methods.
@protocol PayPalProfileSharingDelegate <NSObject>
@required

/// User canceled without consenting.
/// @param profileSharingViewController The PayPalProfileSharingViewController that the user canceled without consenting.
- (void)userDidCancelPayPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController;

/// User successfully logged in and consented.
/// @param profileSharingViewController The PayPalProfileSharingViewController where the user successfully consented.
/// @param authorization The authorization response, which you will return to your server.
- (void)payPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController
             userDidLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization;

@end


#pragma mark - PayPalProfileSharingViewController

@interface PayPalProfileSharingViewController : UINavigationController

/// Delegate access
@property (nonatomic, weak, readonly) id<PayPalProfileSharingDelegate> profileSharingDelegate;

/// The designated initalizer. A new view controller MUST be initialized for each use.
/// @param scopeValues Set of requested scope-values. Each scope-value is defined in PayPalOAuthScopes.h.
/// @param configuration The configuration to be used for the lifetime of the controller
///     The configuration properties merchantName, merchantPrivacyPolicyURL, and merchantUserAgreementURL must be provided.
/// @param delegate The delegate you want to receive updates about the profile-sharing authorization.
- (instancetype)initWithScopeValues:(NSSet *)scopeValues
                      configuration:(PayPalConfiguration *)configuration
                           delegate:(id<PayPalProfileSharingDelegate>)delegate;

@end