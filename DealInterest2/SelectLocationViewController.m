//
//  SelectLocationViewController.m
//  DealInterest2
//
//  Created by xiaoming on 31/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "SelectLocationViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"

@implementation UIImage (UIImageAdditionalMethod)
- (UIImage *)imageTintedWithColor:(UIColor *)color
{
	if (color) {
		UIGraphicsBeginImageContextWithOptions([self size], NO, 0.f);
		
		CGRect rect = CGRectZero;
		rect.size = [self size];
		
		[color set];
		UIRectFill(rect);
		
		[self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
		
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return image;
	}
	
	return self;
}

- (UIImage *)changeImageSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

@interface SelectLocationViewController ()
@property (nonatomic, strong) LPGoogleFunctions *googleFunctions;
@property (nonatomic, strong) NSMutableArray *placesList;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation SelectLocationViewController

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
    //[self loadPlacesAutocompleteForInput:@"Nanyang"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.placesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // LPCell *cell = [LPCell cellFromNibNamed:@"LPCell"];
    //http://stackoverflow.com/questions/8066668/ios-5-uisearchdisplaycontroller-crash
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationTableCell"];
    
    LPPlaceDetails *placeDetails = (LPPlaceDetails *)[self.placesList objectAtIndex:indexPath.row];
    
    UILabel *topLabel = (UILabel *)[cell viewWithTag:101];
    topLabel.text = placeDetails.name;
    
    UILabel *bottomLabel = (UILabel *)[cell viewWithTag:102];
    bottomLabel.text = placeDetails.formattedAddress;
    
    
    [self setImageForCell:cell fromURL:placeDetails.icon withColor:[UIColor colorWithRed:(170.0/255.0) green:(170.0/255.0) blue:(170.0/255.0) alpha:1.0]];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPPlaceDetails *placeDetails = (LPPlaceDetails *)[self.placesList objectAtIndex:indexPath.row];
    if ([self.searchDisplayController isActive]) {
        [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
        NSLog(@"Hello");
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSLog(@"Hiya");
    }
    [self.delegate returnFromLocation:placeDetails.name address:placeDetails.formattedAddress lat:placeDetails.geometry.location.latitude lng:placeDetails.geometry.location.longitude];
}

#pragma mark - LPGoogleFunctions

- (LPGoogleFunctions *)googleFunctions
{
    if (!_googleFunctions) {
        _googleFunctions = [LPGoogleFunctions new];
        _googleFunctions.googleAPIBrowserKey = googleAPIBrowserKey;
        _googleFunctions.delegate = self;
        _googleFunctions.sensor = YES;
        _googleFunctions.languageCode = @"en";
    }
    return _googleFunctions;
}

- (void)loadPlacesAutocompleteForInput:(NSString *)input
{
    self.searchDisplayController.searchBar.text = input;
    
    [self.googleFunctions loadPlacesAutocompleteWithDetailsForInput:input offset:(int)[input length] radius:0 location:nil placeType:LPGooglePlaceTypeUnknown countryRestriction:@"sg" successfulBlock:^(NSArray *placesWithDetails) {
        NSLog(@"successful = %@", placesWithDetails[0]);
        
        self.placesList = [NSMutableArray arrayWithArray:placesWithDetails];
        
        if ([self.searchDisplayController isActive]) {
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            [self.tableView reloadData];
        }
    } failureBlock:^(LPGoogleStatus status) {
        NSLog(@"Error - Block: %@", [LPGoogleFunctions getGoogleStatus:status]);
        
        self.placesList = [NSMutableArray new];
        
        if ([self.searchDisplayController isActive]) {
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - LPGoogleFunctions Delegate

- (void)googleFunctionsWillLoadPlacesAutocomplate:(LPGoogleFunctions *)googleFunctions forInput:(NSString *)input
{
    NSLog(@"willLoadPlacesAutcompleteForInput: %@", input);
}

- (void)googleFunctions:(LPGoogleFunctions *)googleFunctions didLoadPlacesAutocomplate:(LPPlacesAutocomplete *)placesAutocomplate
{
    NSLog(@"didLoadPlacesAutocomplete - Delegate");
}

- (void)googleFunctions:(LPGoogleFunctions *)googleFunctions errorLoadingPlacesAutocomplateWithStatus:(LPGoogleStatus)status
{
    NSLog(@"errorLoadingPlacesAutocomplateWithStatus - Delegate: %@", [LPGoogleFunctions getGoogleStatus:status]);
}

#pragma mark - Search Controller

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self loadPlacesAutocompleteForInput:searchText];
}

#pragma mark - LPImage

- (void)setImageForCell:(UITableViewCell *)cell fromURL:(NSString *)URL withColor:(UIColor *)color
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        imageView.image = [[image imageTintedWithColor:color] changeImageSize:CGSizeMake(24.0f, 24.0f)];
        
    } failure:nil];
}

@end
