//
//  SearchFilterTableViewController.m
//  DealInterest2
//
//  Created by xiaoming on 6/8/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "SearchFilterTableViewController.h"
#import "Helper.h"

@interface SearchFilterTableViewController ()
@property NSIndexPath *lastIndexPath;
@property (weak, nonatomic) IBOutlet UITextField *priceRangeFromField;
@property (weak, nonatomic) IBOutlet UITextField *priceRangeToField;
@end

@implementation SearchFilterTableViewController

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
    
    self.lastIndexPath = [NSIndexPath indexPathForRow:self.sortBy inSection:0];
    self.priceRangeFromField.text = [NSString stringWithFormat:@"$%.2f", self.priceRangeFrom];
    self.priceRangeToField.text = [NSString stringWithFormat:@"$%.2f", self.priceRangeTo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)apply:(id)sender {
    NSLog(@"Sort By = %d", self.sortBy);
    self.delegate.sortBy = self.sortBy;
    
    // Remove dollar sign
    NSRange range = NSMakeRange(0,1);
    NSString *price = [self.priceRangeFromField.text stringByReplacingCharactersInRange:range withString:@""];
    self.delegate.priceRangeFrom = [price floatValue];
    
    price = [self.priceRangeToField.text stringByReplacingCharactersInRange:range withString:@""];
    self.delegate.priceRangeTo = [price floatValue];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)priceChanged:(id)sender {
    UITextField *priceTextBox = (UITextField *)sender;
    NSLog(@"haha");
    [Helper adjustTextFieldForPrice:priceTextBox];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    //NSLog(@"Section = %ld, Row = %ld", (long)indexPath.section, (long)indexPath.row);
    //NSLog(@"cell = %@", cell);
    
    if ([indexPath compare:self.lastIndexPath] == NSOrderedSame)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
 }

// UITableView Delegate Method
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Section = %ld, Row = %ld", (long)indexPath.section, (long)indexPath.row);
    if (indexPath.section == 0) {
        self.lastIndexPath = indexPath;
        self.sortBy = indexPath.row;
        [tableView reloadData];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([cell.reuseIdentifier isEqualToString:@"priceRangeFromCell"]) {
        [self.priceRangeFromField becomeFirstResponder];
    } else if ([cell.reuseIdentifier isEqualToString:@"priceRangeToCell"]) {
        [self.priceRangeToField becomeFirstResponder];
    }
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: = forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
