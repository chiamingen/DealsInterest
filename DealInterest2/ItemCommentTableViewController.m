//
//  ItemCommentTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 24/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ItemCommentTableViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"

@interface ItemCommentTableViewController ()

@end

@implementation ItemCommentTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// http://stackoverflow.com/questions/6216839/how-to-add-spacing-between-uitableviewcell
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Number of rows is the number of time zones in the region for the specified section.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentData count];
}

// http://useyourloaf.com/blog/2014/02/14/table-view-cells-with-varying-row-heights.html
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableCell"];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableCell"];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath = %ld, %d", (long)[indexPath section], [indexPath row]);
    NSDictionary *comment = [self.commentData objectAtIndex:indexPath.row];
    NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, comment[@"fields"][@"profile_pic"]]];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:100];
    image.layer.cornerRadius = 19.5;
    image.clipsToBounds = YES;
    [image setImageWithURL:profilePicUrl placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
    
    UILabel *words = (UILabel *)[cell viewWithTag:101];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", comment[@"fields"][@"name"], comment[@"fields"][@"comment"]]];
    [content addAttribute:NSForegroundColorAttributeName value:self.navigationController.view.tintColor range:NSMakeRange(0, [comment[@"fields"][@"name"] length])];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:14] range:NSMakeRange(0, [content length])];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-bold" size:14] range:NSMakeRange(0, [comment[@"fields"][@"name"] length])];
    words.attributedText = content;
    
    UILabel *date = (UILabel *)[cell viewWithTag:102];
    date.text = [Helper calculateDate:comment[@"fields"][@"date"]];
}

@end
