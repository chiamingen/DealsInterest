//
//  ItemDescFieldViewController.m
//  DealInterest2
//
//  Created by xiaoming on 10/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "ItemDescFieldViewController.h"

@interface ItemDescFieldViewController ()
@property (weak, nonatomic) IBOutlet UILabel *placeholder;

@end

@implementation ItemDescFieldViewController

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
    
    if ([self.description length] > 0) {
        self.placeholder.hidden = YES;
    }
    self.textField.text = self.description;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// http://stackoverflow.com/questions/15881454/why-uitextview-does-not-have-placeholder-property-like-uitextfield
- (void)textViewDidChange:(UITextView *)txtView
{
    self.placeholder.hidden = ([txtView.text length] > 0);
}

- (void)textViewDidEndEditing:(UITextView *)txtView
{
    self.placeholder.hidden = ([txtView.text length] > 0);
}

- (IBAction)done:(id)sender {
    [self.delegate returnFromDescField:self.textField.text];
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