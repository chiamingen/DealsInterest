//
//  ListFeedbackViewController.m
//  DealInterest2
//
//  Created by xiaoming on 4/8/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ListFeedbackViewController.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"

@interface ListFeedbackViewController ()
@property (weak, nonatomic) IBOutlet UITableView *feedbackTable;
@property (weak, nonatomic) IBOutlet UILabel *feedbackPositive;
@property (weak, nonatomic) IBOutlet UILabel *feedbackNeutral;
@property (weak, nonatomic) IBOutlet UILabel *feedbackNegative;
@property (weak, nonatomic) IBOutlet UISegmentedControl *feedbackOption;
@property NSMutableArray *defaultFeedbackData;
@property NSMutableArray *feedbackData;
@end

@implementation ListFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)changeFeedbackOption:(id)sender {
    NSLog(@"self.feedbackRating.selectedSegmentIndex = %d", self.feedbackOption.selectedSegmentIndex);
    switch (self.feedbackOption.selectedSegmentIndex) {
        case 0: {
            self.feedbackData = self.defaultFeedbackData;
            [self.feedbackTable reloadData];
            break;
        }
        case 1: {
            NSMutableArray *data = [[NSMutableArray alloc] init];
            for (NSDictionary *feedback in self.defaultFeedbackData) {
                if ([feedback[@"is_seller"]integerValue] == 1) {
                    [data addObject:feedback];
                }
            }
            self.feedbackData = data;
            [self.feedbackTable reloadData];
            break;
        }
        case 2: {
            NSMutableArray *data = [[NSMutableArray alloc] init];
            for (NSDictionary *feedback in self.defaultFeedbackData) {
                if ([feedback[@"is_seller"]integerValue] == 0) {
                    [data addObject:feedback];
                }
            }
            self.feedbackData = data;
            [self.feedbackTable reloadData];
            break;
        }
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Feedback";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *url = [NSString stringWithFormat:@"%@json/feedback.list/", ServerBaseUrl];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    NSDictionary *parameters = @{@"user_id": userID};
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Get Feedback JSON: %@", responseObject);
        
        // User Feedback
        self.feedbackPositive.text = [NSString stringWithFormat:@"%@", responseObject[@"feedback_positive"]];
        self.feedbackNeutral.text = [NSString stringWithFormat:@"%@", responseObject[@"feedback_neutral"]];
        self.feedbackNegative.text = [NSString stringWithFormat:@"%@", responseObject[@"feedback_negative"]];
        self.feedbackPositive.hidden = NO;
        self.feedbackNeutral.hidden = NO;
        self.feedbackNegative.hidden = NO;
        
        self.defaultFeedbackData = [responseObject[@"feedback"] mutableCopy];
        self.feedbackData = [responseObject[@"feedback"] mutableCopy];
        [self.feedbackTable reloadData];
        
        [hud hide:YES];
    } failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// http://stackoverflow.com/questions/6216839/how-to-add-spacing-between-uitableviewcell
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Number of rows is the number of time zones in the region for the specified section.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedbackData count];
}

// http://useyourloaf.com/blog/2014/02/14/table-view-cells-with-varying-row-heights.html
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedbackTableCell"];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}
/*
 - (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return UITableViewAutomaticDimension;
 }
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedbackTableCell"];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath = %ld, %d", (long)[indexPath section], [indexPath row]);
    NSDictionary *feedback = [self.feedbackData objectAtIndex:indexPath.row];
    NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, feedback[@"profile_pic"]]];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:100];
    image.layer.cornerRadius = 19.5;
    image.clipsToBounds = YES;
    [image setImageWithURL:profilePicUrl placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
    
    UILabel *words = (UILabel *)[cell viewWithTag:101];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", feedback[@"name"], feedback[@"content"]]];
    [content addAttribute:NSForegroundColorAttributeName value:self.navigationController.view.tintColor range:NSMakeRange(0, [feedback[@"name"] length])];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:14] range:NSMakeRange(0, [content length])];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-bold" size:14] range:NSMakeRange(0, [feedback[@"name"] length])];
    words.attributedText = content;
    
    UILabel *date = (UILabel *)[cell viewWithTag:102];
    date.text = [Helper calculateDate:feedback[@"date"]];
    
    UIImageView *icon = (UIImageView *)[cell viewWithTag:103];
    switch ([feedback[@"rating"] integerValue]) {
        case 0: {
            icon.image = [UIImage imageNamed:@"lol-32"];
            break;
        }
        case 1: {
            icon.image = [UIImage imageNamed:@"happy-32"];
            break;
        }
        case 2: {
            icon.image = [UIImage imageNamed:@"sad-32"];
            break;
        }
        default:
            break;
    }

}

@end
