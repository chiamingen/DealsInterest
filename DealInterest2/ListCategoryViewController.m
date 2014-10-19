//
//  CategoryViewController.m
//  DealInterest2
//
//  Created by xiaoming on 25/5/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ListCategoryViewController.h"
#import "CategoryViewController.h"
#import "Constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "Helper.h"
#import "AppDelegate.h"

@interface ListCategoryViewController ()

@property NSMutableArray *categoryData;

@end

@implementation ListCategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)testing:(id)sender {
    NSLog(@"Push");
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(80, 0.0, 0.0, 0);
    [self.collectionView setContentInset:contentInsets];
    [self.collectionView setScrollIndicatorInsets:contentInsets];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup the activity indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    // Prepare the category JSON URL
    NSString *url = [NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/item.category"];
    
    // Fetch the category JSON from server
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Store the category JSON into array for later use
        self.categoryData = responseObject;
        
        // Update the screen
        [self.collectionView reloadData];
        
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Hide the activity indicator
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"Error: %@", error);
        [Helper popupAlert:[NSString stringWithFormat:@"%@", error]];
    }];
    
    // http://stackoverflow.com/questions/1449339/how-do-i-change-the-title-of-the-back-button-on-a-navigation-bar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)testing2:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    UIView *controllerView = imagePickerController.view;
    
    //controllerView.alpha = 0.0;
    controllerView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    imagePickerController.showsCameraControls = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *UI = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"cameraView"];
    imagePickerController.cameraOverlayView  = UI.view;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categoryData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CategoryCell";
    
    // Get the cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // Get the activity indicator of this cell
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:102];
    
    // Extract the category data from array needed for this specific cell
    NSDictionary *category = [self.categoryData objectAtIndex:indexPath.row];
    NSLog(@"%@", [NSString stringWithFormat:@"%@%@", ServerBaseUrl, category[@"fields"][@"category_pic"]]);
    
    // Get the ImageView of this cell
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    
    // Load the image into the cell's ImageView
    NSURL *imgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, category[@"fields"][@"category_pic"]]];
    [cellImageView setImageWithURL:imgUrl placeholderImage:nil options:SDWebImageRetryFailed  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        [activityIndicator startAnimating];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [activityIndicator stopAnimating];
        // Show error if there is any problems
        if (error) {
            NSLog(@" error => %@ ", [error userInfo] );
            NSLog(@" error => %@ ", [error localizedDescription] );
        }
    }];
    
    // Update the name of this category
    UILabel *categoryName = (UILabel *)[cell viewWithTag:101];
    categoryName.text = category[@"fields"][@"category_name"];
    
    // Add border to cell. Find color at http://uicolor.org/
    //cell.layer.borderWidth=1.0f;
    //UIColor * color = [UIColor colorWithRed:206/255.0f green:206/255.0f blue:206/255.0f alpha:1.0f];
    //cell.layer.borderColor= color.CGColor;
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 4.0f;
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"goToCategoryPage"])
    {
        
        // Get the category controller
        CategoryViewController *destViewController = segue.destinationViewController;
        
        // Method for getting the indexPath
        // http://www.appcoda.com/ios-collection-view-tutorial/
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        // Get category data for the selected cell
        NSDictionary *category = [self.categoryData objectAtIndex:indexPath.row];
        
        // Pass the category name to the category controller
        destViewController.categoryName = category[@"fields"][@"category_name"];
    }
}

- (IBAction)logout:(id)sender {
    NSLog(@"Logout");
    
    // Reset tab controller to first tab so that when user login later they will be at first tab not at profile tab.
    [self.tabBarController setSelectedIndex:0];
    
    // Clear all user data
    // http://stackoverflow.com/questions/545091/clearing-nsuserdefaults
    NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    
    // Show login screen
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoginScreen:YES];
}

@end
