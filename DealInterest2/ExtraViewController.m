//
//  ExtraViewController.m
//  DealInterest2
//
//  Created by xiaoming on 3/8/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ExtraViewController.h"
#import "HMSegmentedControl.h"
#import "TestingGPSViewController.h"
#import "AppDelegate.h"
#import "LatestItemViewController.h"

@interface ExtraViewController ()
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property NSInteger numOfPage;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *control;
@property NSMutableArray *viewControllerArray;
@property NSInteger currentIndex;
@end

@implementation ExtraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (IBAction)testing:(id)sender {
    NSLog(@"self.container.frame.size.height = %f", self.container.frame.size.height);
    LatestItemViewController *viewCon = (LatestItemViewController *)[self viewControllerAtIndex:0];
    NSLog(@"contentSize height = %f", viewCon.collectionView.contentSize.height);
    NSLog(@"collectionView.frame height = %f", viewCon.collectionView.frame.size.height);
    viewCon.collectionView.frame = CGRectMake(0, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
    NSLog(@"collectionView.frame height = %f", viewCon.collectionView.frame.size.height);

    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate showItemScreen:130 itemName:@"LOL" isEditable:NO navController:self.navigationController];
}

 */

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.numOfPage = 3;
    
    UIViewController *firstCon = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstExtraContentViewController"];
    UIViewController *secondCon = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondExtraContentViewController"];
    TestingGPSViewController *thirdCon = [self.storyboard instantiateViewControllerWithIdentifier:@"ThirdExtraContentViewController"];
    thirdCon.parentNavCon = self.navigationController;
    self.viewControllerArray = [[NSMutableArray alloc] initWithArray:@[firstCon, secondCon, thirdCon]];
    
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Latest", @"Following", @"Nearby"]];
    segmentedControl.frame = CGRectMake(0, 0, 320, self.control.frame.size.height);
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl.font = [UIFont fontWithName:@"Helvetica" size:15];
    segmentedControl.selectionIndicatorColor = [self.navigationController.view.tintColor colorWithAlphaComponent:0.5f];
    
    [segmentedControl setIndexChangeBlock:^(NSInteger index) {
        UIViewController *startingViewController = [self viewControllerAtIndex:index];
        NSArray *viewControllers = @[startingViewController];
        if (index > self.currentIndex) {
            [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        } else {
            [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
        }
        self.currentIndex = index;
    }];
    [self.control addSubview:segmentedControl];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ExtraPageViewController"];
    self.pageViewController.dataSource = self;
    
    // http://stackoverflow.com/questions/22098493/uipageviewcontroller-disable-swipe-gesture
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
                        view.scrollEnabled = NO;
        }
    }
    
    UIViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index;
    if ([viewController.restorationIdentifier isEqualToString:@"FirstExtraContentViewController"]) {
        index = 0;
    } else if ([viewController.restorationIdentifier isEqualToString:@"SecondExtraContentViewController"]) {
        index = 1;
    } else {
        index = 2;
    }
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index;
    if ([viewController.restorationIdentifier isEqualToString:@"FirstExtraContentViewController"]) {
        index = 0;
    } else if ([viewController.restorationIdentifier isEqualToString:@"SecondExtraContentViewController"]) {
        index = 1;
    } else {
        index = 2;
    }
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == self.numOfPage) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((self.numOfPage == 0) || (index >= self.numOfPage)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    if (index == 0) {
        return [self.viewControllerArray objectAtIndex:0];
    } else if (index == 1) {
        return [self.viewControllerArray objectAtIndex:1];
    } else {
        return [self.viewControllerArray objectAtIndex:2];
    }
}


@end
