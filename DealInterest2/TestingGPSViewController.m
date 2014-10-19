//
//  TestingGPSViewController.m
//  DealInterest2
//
//  Created by xiaoming on 1/8/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "TestingGPSViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "CustomInfoWindow.h"
#import "AppDelegate.h"

@interface TestingGPSViewController ()
@property (weak, nonatomic) IBOutlet GMSMapView *map;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UISlider *questionSlider;
@property (nonatomic) float lastQuestionStep;
@property (nonatomic) float stepValue;
@property float currentDistance;
@end

@implementation TestingGPSViewController {
    GMSCameraPosition *camera;
    NSMutableArray *markersArray;
}

- (IBAction)sliderChanged:(id)sender {
    float newStep = roundf((self.questionSlider.value) / self.stepValue);
    
    // Convert "steps" back to the context of the sliders values.
    self.questionSlider.value = newStep * self.stepValue;
    self.distanceLabel.text = [NSString stringWithFormat:@"Displaying item within %.01f KM", self.questionSlider.value];
    
    if (self.currentDistance != self.questionSlider.value) {
        self.currentDistance = self.questionSlider.value;
        [self getNearbyItem];
    }
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
    
    NSLog(@"Map controller");
    // Do any additional setup after loading the view.
    self.currentDistance = self.questionSlider.value;
    self.distanceLabel.text = [NSString stringWithFormat:@"Displaying item within %.01f KM", self.questionSlider.value];
    
    self.stepValue = 0.5f;
    // Set the initial value to prevent any weird inconsistencies.
    self.lastQuestionStep = (self.questionSlider.value) / self.stepValue;
    
    markersArray = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [self.locationManager startUpdatingLocation];
    
    float latitude = self.locationManager.location.coordinate.latitude;
    float longitude = self.locationManager.location.coordinate.longitude;
    
    camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:14];
    //mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.map.camera = camera;
    self.map.myLocationEnabled = YES;
    self.map.delegate = self;
    
    [self getNearbyItem];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    NSLog(@"Tapped = %@", marker.userData[@"title"]);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showItemScreen:[marker.userData[@"item_id"] integerValue] itemName:marker.userData[@"title"] isEditable:NO navController:self.parentNavCon];
}

- (UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    infoWindow.itemName.text = marker.userData[@"title"];
   infoWindow.itemPrice.text = [NSString stringWithFormat:@"$%@", marker.userData[@"price"]];
    
    
    // Load user profile pic
   NSURL *profilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, marker.userData[@"photo"]]];
    //NSLog(@"URL = %@", profilePicUrl);
    infoWindow.itemPhoto.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profilePicUrl]];
/*
  // [infoWindow.itemPhoto setImageWithURL:profilePicUrl placeholderImage:[UIImage imageNamed:@"profile_default.jpg"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:profilePicUrl];
    
    __weak UIImageView *imageView = infoWindow.itemPhoto;
    
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"image loaded");
        imageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error = %@", error);
        NSLog(@"response = %@", response);
    }];
 */

    return infoWindow;
}

-(void)getNearbyItem {
    // Setup the activity indicator
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"Loading Item";
    
    float latitude = self.locationManager.location.coordinate.latitude;
    float longitude = self.locationManager.location.coordinate.longitude;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"lat": @(latitude), @"lng": @(longitude), @"distance": @(self.questionSlider.value) };
    NSLog(@"parameters = %@", parameters);
    
    [manager POST:[NSString stringWithFormat:@"%@%@", ServerBaseUrl, @"json/item.getNearbyItem/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // NSLog(@"JSON %@", responseObject);
        
        [self.map clear];
        
        CLLocationCoordinate2D circleCenter = CLLocationCoordinate2DMake(latitude, longitude);
        GMSCircle *circ = [GMSCircle circleWithPosition:circleCenter
                                                 radius:(self.currentDistance * 1000)];
        circ.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.05];
        circ.strokeColor = [UIColor blueColor];
        circ.strokeWidth = 2;
        circ.map = self.map;
        
        for (NSDictionary* item in responseObject) {
            NSLog(@"- %@", item);
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake([item[@"lat"] floatValue], [item[@"lng"] floatValue]);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            marker.snippet = item[@"title"];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = self.map;
            marker.userData = item;
            [markersArray addObject:marker];
        }
        
        // Hide the activity indicator
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)testing:(id)sender {
    float latitude = self.locationManager.location.coordinate.latitude;
    float longitude = self.locationManager.location.coordinate.longitude;
    NSLog(@"latitude = %f, longitude = %f", latitude, longitude);
    
    [self.map clear];
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
