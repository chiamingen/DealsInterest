//
//  CommentViewController.m
//  DealInterest2
//
//  Created by xiaoming on 12/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "CommentViewController.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
#import <SVPullToRefresh.h>

@interface CommentViewController ()

@property NSMutableArray *commentData;
@property (weak, nonatomic) IBOutlet UITableView *commentTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendMessageButton;
@property (weak, nonatomic) IBOutlet UITextField *messageComposeTextField;
@property (weak, nonatomic) IBOutlet UIToolbar *chatToolBar;
@property BOOL stayup;
@property UIRefreshControl *refreshControl;
@end

@implementation CommentViewController

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
    NSLog(@"Comment - viewDidLoad self.itemID = %@", self.itemID);
    self.stayup = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    __weak CommentViewController *tmpSelf= self;
    [self.commentTable addPullToRefreshWithActionHandler:^{
        // prepend data to dataSource, insert cells at top of table view
        // call [tableView.pullToRefreshView stopAnimating] when done
        [tmpSelf getComments:YES];
    }];
    
    [self getComments:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getComments:(BOOL)isPullToRefresh {
    // Setup the activity indicator
    if (!isPullToRefresh) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading Comments";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    // Prepare the comment JSON URL
    //self.itemID = @"131";
    NSString *commentUrl = [NSString stringWithFormat:@"%@json/comment.getByItem/%@", ServerBaseUrl, self.itemID];
    
    [manager GET:commentUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"Get Comment JSON: %@", responseObject);
        
        NSDictionary *firstElement = [responseObject objectAtIndex:0];
        if ([firstElement[@"responseText"] isEqualToString:@"Success!"]) {
            self.commentData = [responseObject mutableCopy];
        } else {
            self.commentData = [[NSMutableArray alloc] init];
        }
        
        
        if (!isPullToRefresh) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            [self.commentTable.pullToRefreshView stopAnimating];
        }
        
        [self.commentTable reloadData];
        
        // Scroll to bottom
        // NSIndexPath* ipath = [NSIndexPath indexPathForRow:[self.commentData count]-1 inSection:0];
        // [self.commentTable scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
        
        
    } failure:nil];
}


- (IBAction)sendComment:(id)sender {
    NSString *comment = self.messageComposeTextField.text;
    
    // Dismiss the keyboard
    [self.view endEditing:YES];
    self.messageComposeTextField.text = @"";
    self.sendMessageButton.enabled = NO;
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sending Comment";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *itemID = self.itemID;
    NSString *userID = [prefs objectForKey:@"userID"];
    NSString *name = [prefs objectForKey:@"username"];
    NSString *replyToID = self.itemUserID;
    NSString *replyToIDAndroid = self.itemUserID;
    NSString *deviceID = [prefs objectForKey:@"deviceID"];
    NSString *token = [prefs objectForKey:@"token"];
    NSString *profilePic = [prefs objectForKey:@"profilePic"];
    
    NSLog(@"Sending comment = %@", comment);
    
    // Setup the URL for fetching the JSON from the server which contain all the item for this category
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/comment.insert/"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"item_id": itemID,
                                 @"user_id": userID,
                                 @"name": name,
                                 @"comment": comment,
                                 @"replyto_id": replyToID,
                                 @"replyto_id_android": replyToIDAndroid,
                                 @"device_id": deviceID,
                                 @"token": token
                                 };
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *now = [NSDate date];
        NSLog(@"%@",[dateFormatter stringFromDate:now]);
        
        NSDictionary *newCommentData = [NSDictionary dictionaryWithObjectsAndKeys:
                                        profilePic, @"profile_pic",
                                        name, @"name",
                                        [dateFormatter stringFromDate:now], @"date",
                                        comment, @"comment", nil];
        NSDictionary *newComment = [NSDictionary dictionaryWithObjectsAndKeys:
                                    newCommentData, @"fields", nil];
        
        [self.commentData insertObject:newComment atIndex:0];
        
        [self.commentTable reloadData];
        
        if ([self.commentData count] > 3) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCommentViewNotification" object:self userInfo:@{@"comments": [self.commentData subarrayWithRange:NSMakeRange(0, 3)]}];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCommentViewNotification" object:self userInfo:@{@"comments": self.commentData}];
        }
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}

- (IBAction)closeCommentPage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate methods

// Override to dynamically enable/disable the send button based on user typing
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger length = self.messageComposeTextField.text.length - range.length + string.length;
    if (length > 0) {
        self.sendMessageButton.enabled = YES;
    }
    else {
        self.sendMessageButton.enabled = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

// Delegate method called when the message text field is resigned.
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Check if there is any message to send
    if (self.messageComposeTextField.text.length) {
        // Resign the keyboard
        [textField resignFirstResponder];
        
        // Send the message
        /*
        Transcript *transcript = [self.sessionContainer sendMessage:self.messageComposeTextField.text];
        
        if (transcript) {
            // Add the transcript to the table view data source and reload
            [self insertTranscript:transcript];
        }
        */
        // Clear the textField and disable the send button
        self.messageComposeTextField.text = @"";
        self.sendMessageButton.enabled = NO;
    }
}

#pragma mark - Toolbar animation helpers

// Helper method for moving the toolbar frame based on user action
- (void)moveToolBarUp:(BOOL)up forKeyboardNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    NSLog(@"Push toolbar");
    [self.chatToolBar setFrame:CGRectMake(self.chatToolBar.frame.origin.x, self.chatToolBar.frame.origin.y + (keyboardFrame.size.height * (up ? -1 : 1)), self.chatToolBar.frame.size.width, self.self.chatToolBar.frame.size.height)];
    //[self.commentTable setFrame:CGRectMake(self.commentTable.frame.origin.x, self.commentTable.frame.origin.y, self.commentTable.frame.size.width, (self.commentTable.frame.size.height + (keyboardFrame.size.height * (up ? -1 : 1))))];
    [UIView commitAnimations];
    // Push comment up
    //CGSize kbSize = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Flip kbSize if landscape.
    //if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
      //  kbSize = CGSizeMake(kbSize.height, kbSize.width);
    //}
    
    // http://stackoverflow.com/questions/19407790/how-to-move-textview-and-tableview-with-keyboard
    if (up) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.height, 0);
        [self.commentTable setContentInset:contentInsets];
        [self.commentTable setScrollIndicatorInsets:contentInsets];
    } else {
        // http://code.tutsplus.com/tutorials/ios-sdk-keeping-content-from-underneath-the-keyboard--mobile-6103
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        [self.commentTable setContentInset:contentInsets];
        [self.commentTable setScrollIndicatorInsets:contentInsets];
    }
    
    /*
    CGPoint scrollPoint = CGPointMake(0.0, self.commentTable.contentSize.height - keyboardFrame.size.height);
    [self.commentTable setContentOffset:scrollPoint animated:YES];
     */
}


- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"Push keyboardWillShow");
    // move the toolbar frame up as keyboard animates into view
    [self moveToolBarUp:YES forKeyboardNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification {
     NSLog(@"Push keyboardWillHide");
    // move the toolbar frame down as keyboard animates into view
    [self moveToolBarUp:NO forKeyboardNotification:notification];
}

@end
