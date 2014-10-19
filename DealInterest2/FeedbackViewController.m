//
//  FeedbackViewController.m
//  DealInterest2
//
//  Created by xiaoming on 2/8/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Helper.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "MBProgressHUD.h"

@interface FeedbackViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *feedbackRating;
@property (weak, nonatomic) IBOutlet UITextView *feedbackContent;

@end

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Helper drawTopBottomBorder:self.feedbackContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submit:(id)sender {
    // Dismiss the keyboard
    [self.view endEditing:YES];
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Submiting Feedback";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"%@json/feedback.insert/", ServerBaseUrl];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *fromUserId = [prefs objectForKey:@"userID"];
    
    NSDictionary *parameters = @{
                                 @"item_id": self.itemID,
                                 @"from_user_id": fromUserId,
                                 @"to_user_id": self.toUserID,
                                 @"content": self.feedbackContent.text,
                                 @"rating": @(self.feedbackRating.selectedSegmentIndex),
                                 @"is_seller": @(self.isSeller)
                                 };
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Get Feedback JSON: %@", responseObject);
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:nil];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
