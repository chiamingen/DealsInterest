//
//  ImagePageContentViewController.m
//  DealInterest2
//
//  Created by xiaoming on 11/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ImagePageContentViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"

@interface ImagePageContentViewController ()
@end

@implementation ImagePageContentViewController

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
    NSLog(@"ImagePageContentViewController");
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, self.imageFile]];
    [self.imageView setImageWithURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
