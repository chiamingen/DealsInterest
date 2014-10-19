//
//  ItemViewController.m
//  DealInterest2
//
//  Created by xiaoming on 26/5/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ItemViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "OthersProfileViewController.h"
#import "ImagePageViewController.h"
#import "UploadItemViewController.h"
#import "ImagePageContentViewController.h"
#import "CommentViewController.h"
#import "ListOfferViewController.h"
#import "BuyerOfferViewController.h"

@interface ItemViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *itemLocation;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *priceToolbar;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UILabel *itemNoOfLikes;
@property (weak, nonatomic) IBOutlet UITableView *commentTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentTableHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *itemDate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *viewAllCommentButton;
@property (weak, nonatomic) IBOutlet UIToolbar *buyerToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *sellerToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sellerToobarText;
@property (weak, nonatomic) IBOutlet UIButton *sellerToolbarButton;
@property NSDictionary *itemData;
@property NSMutableArray *commentData;
@property BOOL hasItemLiked;
@property (weak, nonatomic) IBOutlet UIImageView *commentIcon;
@property ImagePageViewController *imagePage;
@end

@implementation ItemViewController

- (IBAction)clickProfile:(id)sender {
    // Show login screen
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showOthersProfileScreen:YES otherUserID:self.itemData[@"fields"][@"user_id"] navController:self.navigationController];
}



-(IBAction)editItem {
    //NSLog(@"Edit Item");
    // Get others profile screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UploadItemViewController *viewController = (UploadItemViewController *)[storyboard instantiateViewControllerWithIdentifier:@"itemFormScreen"];
    viewController.isEditItem = YES;
    
    viewController.itemID = self.itemData[@"pk"];
    viewController.category = self.itemData[@"fields"][@"category"];
    viewController.title = self.itemData[@"fields"][@"title"];
    viewController.price = [NSString stringWithFormat:@"$%.2f", [self.itemData[@"fields"][@"price"] floatValue]];
    viewController.desc = self.itemData[@"fields"][@"description"];
    viewController.photo1 = self.itemData[@"fields"][@"photo1"];
    viewController.photo2 = self.itemData[@"fields"][@"photo2"];
    viewController.photo3 = self.itemData[@"fields"][@"photo3"];
    viewController.photo4 = self.itemData[@"fields"][@"photo4"];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)clickFav:(id)sender {
    NSLog(@"Clicked Fav Button");
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *itemID = self.itemData[@"fields"][@"item_id"];
    NSString *userID = [prefs objectForKey:@"userID"];
    NSString *deviceID = [prefs objectForKey:@"deviceID"];
    NSString *token = [prefs objectForKey:@"token"];
    
    // Prepare the favourite JSON URL
   
    NSString *url;
    if (self.hasItemLiked) {
        url = [NSString stringWithFormat:@"%@json/favourite.remove/", ServerBaseUrl];
        hud.labelText = @"Unlike the item";
    } else {
        url = [NSString stringWithFormat:@"%@json/favourite.insert/", ServerBaseUrl];
        hud.labelText = @"Liking the item";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"item_id": itemID,
                                 @"user_id": userID,
                                 @"device_id": deviceID,
                                 @"token": token
                                 };
    //NSLog(@"params: %@", parameters);
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if (self.hasItemLiked) {
            self.likeButton.image = [UIImage imageNamed:@"like"];
        } else {
            self.likeButton.image = [UIImage imageNamed:@"liked"];
        }
        
        self.hasItemLiked = !self.hasItemLiked;
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}

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
    
    self.itemID = 130;
    self.itemName = @"Test";
    
    [self.commentIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
    
    // Do any additional setup after loading the view.
    if (self.itemEditable) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Edit"
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(editItem)];
        self.navigationItem.rightBarButtonItem = editButton;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshItemDetails:)
                                                 name:@"RefreshItemDetailsNotification"
                                               object:nil];
    
    [self getItemDetails];
    
    [self getFavourite];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self adjustHeightOfTableview];
}

- (void)refreshItemDetails:(NSNotification *)notification {
    NSLog(@"refreshItemDetails");
    [self getItemDetails];
}

-(void)getItemDetails {
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Item";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    // Prepare the category JSON URL
    NSString *itemUrl = [NSString stringWithFormat:@"%@json/browse.getItemInfo2/%ld", ServerBaseUrl, (long)self.itemID];
    
    // Fetch the category JSON from server
    NSLog(@"load item");
    [manager GET:itemUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Store the category JSON into array for later use
        self.itemData = [responseObject objectAtIndex:0];
        NSLog(@"Item JSON: %@", responseObject);
        
        NSLog(@"Done item");
        self.title = self.itemData[@"fields"][@"title"];
        
        self.userName.text = self.itemData[@"fields"][@"user_name"];
        self.price.text = [NSString stringWithFormat:@"$%.2f", [self.itemData[@"fields"][@"price"] floatValue]];
        self.priceToolbar.title = self.price.text;
        self.itemTitle.text = self.itemData[@"fields"][@"title"];
        self.itemDescription.text = self.itemData[@"fields"][@"description"];
        self.itemNoOfLikes.text = [NSString stringWithFormat:@"%@ likes", self.itemData[@"fields"][@"like_no"]];
        self.itemLocation.text = self.itemData[@"fields"][@"location_address"];
        self.itemDate.text = [Helper calculateDate:self.itemData[@"fields"][@"date"]];
        self.userName.hidden = NO;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSInteger userID = [[prefs objectForKey:@"userID"] integerValue];
        if (userID == [self.itemData[@"fields"][@"user_id"] integerValue]) {
            self.sellerToolbar.hidden = NO;
            if ([self.itemData[@"num_of_offer"] integerValue] > 0) {
                self.sellerToobarText.title = [NSString stringWithFormat:@"You have %@ offers", self.itemData[@"num_of_offer"]];
            } else {
                self.sellerToobarText.title = @"You have no offer yet";
                self.sellerToolbarButton.hidden = YES;
            }
        } else {
            self.buyerToolbar.hidden = NO;
        }
        
        // Load the profile pic
        NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, self.itemData[@"fields"][@"profile_pic"]]];
        [self.profilePic setImageWithURL:profilePicUrl];
        
        
        NSMutableArray *images = [NSMutableArray arrayWithObjects: self.itemData[@"fields"][@"photo1"], nil];
        
        if (![self.itemData[@"fields"][@"photo2"] isEqualToString:@""]) {
            [images addObject:self.itemData[@"fields"][@"photo2"]];
        }
        
        self.imagePage.pageImages = images;
        // Create a new view controller and pass suitable data.
        ImagePageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImagePageContentViewController"];
        pageContentViewController.imageFile =  self.imagePage.pageImages[0];
        pageContentViewController.pageIndex = 0;
        [self.imagePage setViewControllers:@[pageContentViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

        // Comments
        NSArray *comments = self.itemData[@"comments"];
        if ([comments count] > 0) {
            self.commentData = [comments mutableCopy];
        } else {
            self.commentData = [[NSMutableArray alloc] init];
        }
        
        [self.commentTable reloadData];
        [self adjustHeightOfTableview];
        
        NSString *buttonTitle = [NSString stringWithFormat:@"View all %@ comments", self.itemData[@"fields"][@"comment_no"]];
        [self.viewAllCommentButton setTitle:buttonTitle forState:UIControlStateNormal];
        
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}


-(void)getFavourite {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"userID"];
    
    // Prepare the check favourite JSON URL
    NSString *favUrl = [NSString stringWithFormat:@"%@json/favourite.check/%ld/%@", ServerBaseUrl, (long)self.itemID, userID];
    
    [manager GET:favUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Check Fav JSON: %@", responseObject);
        
        NSDictionary *result = [responseObject objectAtIndex:0];
        
        if ([result[@"responseText"] isEqualToString:@"Exists"]) {
            self.hasItemLiked = YES;
            self.likeButton.image = [UIImage imageNamed:@"liked"];
        } else {
            self.hasItemLiked = NO;
        }
    } failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"goToImagePageScreen"])
    {
        
        ImagePageViewController *destViewController = segue.destinationViewController;
        self.imagePage = destViewController;
    } else if ([[segue identifier] isEqualToString:@"goToCommentPage"]) {
        UINavigationController *navController = [segue destinationViewController];
        CommentViewController *destViewController = (CommentViewController *)([navController viewControllers][0]);
        destViewController.itemID = self.itemData[@"fields"][@"item_id"];
        destViewController.itemUserID = self.itemData[@"fields"][@"user_id"];
    } else if ([[segue identifier] isEqualToString:@"goToBuyerOfferPage"]) {
        // Get the category controller
        //BuyerOfferViewController *destViewController = segue.destinationViewController;
        //destViewController.itemData = self.itemData;
    } else if ([[segue identifier] isEqualToString:@"goToListOfferPage"]) {
        // Get the category controller
        ListOfferViewController *destViewController = segue.destinationViewController;
        destViewController.itemData = self.itemData;
    }
     
}

// http://stackoverflow.com/questions/6216839/how-to-add-spacing-between-uitableviewcell
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Number of rows is the number of time zones in the region for the specified section.
    return [self.commentData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CommentTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary *comment = [self.commentData objectAtIndex:indexPath.section];
    
    NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, comment[@"fields"][@"profile_pic"]]];
    
    // Make the image with rounded corner
    cell.imageView.layer.cornerRadius = 4;
    cell.imageView.clipsToBounds = YES;
    [cell.imageView setImageWithURL:profilePicUrl placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];

    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", comment[@"fields"][@"name"], comment[@"fields"][@"comment"]]];
    [content addAttribute:NSForegroundColorAttributeName value:self.navigationController.view.tintColor range:NSMakeRange(0, [comment[@"fields"][@"name"] length])];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:14] range:NSMakeRange(0, [content length])];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-bold" size:14] range:NSMakeRange(0, [comment[@"fields"][@"name"] length])];
    cell.textLabel.attributedText = content;
    cell.textLabel.numberOfLines = 99;
    
    NSString *dateString = [Helper calculateDate:comment[@"fields"][@"date"]];
    NSMutableAttributedString *date = [[NSMutableAttributedString alloc] initWithString:dateString];
    [date addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [dateString length])];
    [date addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:11] range:NSMakeRange(0, [dateString length])];
    cell.detailTextLabel.attributedText = date;
    
    /*
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:comment[@"fields"][@"name"]];
    [name addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:15] range:NSMakeRange(0, [comment[@"fields"][@"name"] length])];
    [name addAttribute:NSForegroundColorAttributeName value:self.navigationController.view.tintColor range:NSMakeRange(0, [comment[@"fields"][@"name"] length])];

    cell.textLabel.attributedText = name;
    cell.detailTextLabel.text = comment[@"fields"][@"comment"];
    cell.detailTextLabel.numberOfLines = 99;
     */
    
    return cell;
}

// http://stackoverflow.com/questions/14223931/change-uitableview-height-dynamically
- (void)adjustHeightOfTableview
{
    CGFloat height = self.commentTable.contentSize.height;
    
    // now set the height constraint accordingly
    
    [UIView animateWithDuration:0.25 animations:^{
        self.commentTableHeightConstraint.constant = height;
        [self.view needsUpdateConstraints];
    }];
}

@end
