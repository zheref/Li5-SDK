//
//  ShippingInfoViewController.m
//  li5
//
//  Created by Martin Cocaro on 7/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import MapKit;
@import MBProgressHUD;
@import Li5Api;

#import "ShippingInfoViewController.h"
#import "OrderProcessedViewController.h"
#import "AppDelegate.h"
#import "UIImage+Li5.h"

@interface ShippingInfoViewController ()
{
    BOOL __userLocationShown;
}

@property (weak, nonatomic) IBOutlet MKMapView *map;

@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *zipCode;
@property (weak, nonatomic) IBOutlet UILabel *city;

@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *state;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *shippingAddressMark;

@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationBtn;

@end

@implementation ShippingInfoViewController

@synthesize product;

#pragma mark - View Setup

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    
    [self.currentLocationBtn setImage:[[UIImage imageNamed:@"currentLocation"] blackAndWhiteImage] forState:UIControlStateNormal];
    [self.currentLocationBtn setImage:[UIImage imageNamed:@"currentLocation"] forState:UIControlStateHighlighted];
    
    [self.continueBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] andRect:self.view.bounds] forState:UIControlStateDisabled];
    [self.continueBtn setEnabled:NO];
    
    if ([CLLocationManager locationServicesEnabled])
    {
        if (!_locationManager)
        {
            _locationManager = [[CLLocationManager alloc] init];
//            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = 10.0;
        }
        
        if (!_geocoder)
        {
            _geocoder = [[CLGeocoder alloc] init];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    if (_locationManager) {
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [_locationManager requestWhenInUseAuthorization];
        
        [_locationManager startUpdatingLocation];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
    
    [self.map removeFromSuperview];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)goBack:(id)sender
{
    DDLogVerbose(@"");
    if (self.navigationController.viewControllers.count < 3)
    {
        CATransition *outTransition = [CATransition animation];
        outTransition.duration = 0.3;
        outTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        outTransition.type = kCATransitionPush;
        outTransition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:outTransition forKey:kCATransition];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goNext:(id)sender
{
    DDLogVerbose(@"");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    [[Li5ApiHandler sharedInstance] updateUserWihAddress:self.address.text zipCode:self.zipCode.text city:self.city.text state:self.state country:self.country completion:^(NSError *error) {
        [hud hideAnimated:YES];
        if (error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.userInfo[@"error"][@"message"]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
            [flowController updateUserProfile];
            
            OrderProcessedViewController *processOrder = [self.storyboard instantiateViewControllerWithIdentifier:@"processOrderView"];
            [processOrder setProduct:self.product];
            [self.navigationController pushViewController:processOrder animated:YES];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    DDLogVerbose(@"");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    DDLogVerbose(@"");
    NSString *newAddress = textField.text;
    [self.geocoder geocodeAddressString:newAddress completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        DDLogVerbose(@"Found placemarks: %lu, error: %@", placemarks.count, error);
        if (error == nil && [placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks lastObject];
            
            [self setUserAddress:placemark isUserLocation:NO];
        } else {
            DDLogError(@"%@", error.debugDescription);
            [self cleanUserAddress];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DDLogVerbose(@"");
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MKMapViewDelegate

- (IBAction)findUserLocation:(id)sender
{
    DDLogVerbose(@"");
    __userLocationShown = NO;
    [self mapView:self.map didUpdateUserLocation:self.map.userLocation];
}

- (void)setUserAddress:(CLPlacemark*)placemark isUserLocation:(BOOL)userLocation
{
    DDLogVerbose(@"");
    [self.currentLocationBtn setHighlighted:YES];
    
    self.address.text = [NSString stringWithFormat:@"%@ %@",placemark.subThoroughfare, placemark.thoroughfare];
    self.city.text = placemark.locality;
    self.zipCode.text = placemark.postalCode;
    self.state = placemark.administrativeArea;
    self.country = placemark.country;
    
    [self.map removeAnnotations:self.map.annotations];
    self.shippingAddressMark = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:placemark.addressDictionary];
    if (!userLocation)
    {
        [self.map addAnnotation:self.shippingAddressMark];
        [self.map showAnnotations:@[self.shippingAddressMark] animated:YES];
    }
    else
    {
        [self.map showAnnotations:@[self.map.userLocation] animated:YES];
    }
    
    [self enableContinueButton];
}

- (void)cleanUserAddress
{
    DDLogVerbose(@"");
    [self.currentLocationBtn setHighlighted:NO];
    
    self.city.text = @"";
    self.zipCode.text = @"";
    self.state = @"";
    self.country = @"";
    
    [self enableContinueButton];
}

- (void)enableContinueButton
{
    DDLogVerbose(@"");
    [self.continueBtn setEnabled:(self.address.text.length != 0 && self.city.text.length != 0 && self.zipCode.text.length != 0 && self.state.length != 0 && self.country.length != 0)];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(__userLocationShown) return;
    
    DDLogVerbose(@"Resolving the Address");
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        DDLogVerbose(@"Found placemarks: %lu, error: %@", (unsigned long)placemarks.count, error);
        if (error == nil && [placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks lastObject];
            [self setUserAddress:placemark isUserLocation:YES];
        } else {
            DDLogError(@"%@", error.debugDescription);
            [self cleanUserAddress];
        }
    } ];
    
    [self.locationManager stopUpdatingLocation];
    
    __userLocationShown = YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    DDLogVerbose(@"");
    static NSString* AnnotationIdentifier = @"Li5UserLocation";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    
    if (!pinView) {
        
        MKAnnotationView *customPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        customPinView.image = [UIImage imageNamed:@"location.png"];
        return customPinView;
        
    } else {
        pinView.annotation = annotation;
    }
    
    return pinView;
}

@end
