//
//  ShippingInfoViewController.m
//  li5
//
//  Created by Martin Cocaro on 7/25/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
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
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@property (weak, nonatomic) IBOutlet MKMapView *map;

@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *zipCode;
@property (weak, nonatomic) IBOutlet UILabel *city;

@property (strong, nonatomic, setter=setCreditCardParams:) STPCardParams *cardParams;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *state;

@property (nonatomic, strong) CLGeocoder *geocoder;@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) MKPlacemark *shippingAddressMark;

@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationBtn;
@property (weak, nonatomic) IBOutlet UISwitch *isSameAsBillingAddress;
@property (weak, nonatomic) IBOutlet UILabel *isSameAsBillingAddressLbl;
@property MBProgressHUD *hud;
@property (nonatomic) BOOL isBillingAddress;
@property (nonatomic, setter=setShowSameAsBillingAddress:) BOOL showSameAsBillingAddress;

@end

@implementation ShippingInfoViewController

@synthesize product;

#pragma mark - View Setup

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    
    _isSameAsBillingAddress.hidden = !_showSameAsBillingAddress;
    _isSameAsBillingAddressLbl.hidden = !_showSameAsBillingAddress;
    
    [self.currentLocationBtn setImage:[[UIImage imageNamed:@"currentLocation"] blackAndWhiteImage] forState:UIControlStateNormal];
    [self.currentLocationBtn setImage:[UIImage imageNamed:@"currentLocation"] forState:UIControlStateHighlighted];
    
    [self.continueBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] andRect:self.view.bounds] forState:UIControlStateDisabled];
    [self.continueBtn setEnabled:NO];
    
    if(_isBillingAddress) {
        _titleLbl.text = @"BILLING ADDRESS";
    }
    
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
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Allow Li5 Access your Location"
                                                                           message:@"Li5 uses your location to populate the address for you. Go to Settings->Location and Enable it."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       
                                                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                   }];
            
            [alert addAction:settingsAction];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        [_locationManager startUpdatingLocation];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
    
    //    [self.map removeFromSuperview];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setCreditCardParams:(STPCardParams *)value{
    _cardParams = value;
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

-(void)setIsBillingAddress:(BOOL)value {
    _isBillingAddress = value;
}

-(void)setShowSameAsBillingAddress:(BOOL)value {
    _showSameAsBillingAddress = value;
}


- (IBAction)goNext:(id)sender
{
    DDLogVerbose(@"");
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeIndeterminate;
  
    if(_showSameAsBillingAddress && _isSameAsBillingAddress.on) {
        [self updateAddressWithType:Li5AddressTypeShipping completion:^(NSError *error) {
            
            [self saveCreditCard];
        }];
    }else {
    
        if(_isBillingAddress) {
            [self saveCreditCard];
        }else {
            
            [self updateAddressWithType:Li5AddressTypeShipping completion:^(NSError *error) {
                
                ShippingInfoViewController *shippingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"shippingView"];
                [shippingVC setProduct:self.product];
                [shippingVC setIsBillingAddress:true];
                [shippingVC setShowSameAsBillingAddress:false];
                [shippingVC setCreditCardParams:_cardParams];
                
                [self.navigationController pushViewController:shippingVC animated:YES];
                [self.hud hideAnimated:YES];
            }];
        }
    
    }
}

-(void)saveCreditCard{

    _cardParams.addressZip = self.zipCode.text;
    _cardParams.addressCity = self.city.text;
    _cardParams.addressState = self.state;
    _cardParams.addressCountry = self.country;
    _cardParams.addressLine1 = self.address.text;
    
    [self generateStripeTokenWithParams:_cardParams completion:^(STPToken *token, NSError *error) {
        if (error)
        {
            [self.hud hideAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            
            [[Li5ApiHandler sharedInstance] updateUserWihCreditCard:token.tokenId
                                                              alias: @""
                                                         completion:^(NSError *error) {
                                                             
                                                             if (error)
                                                             {
                                                                 [self.hud hideAnimated:YES];
                                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                                 message:error.localizedDescription
                                                                                                                delegate:self
                                                                                                       cancelButtonTitle:@"OK"
                                                                                                       otherButtonTitles:nil];
                                                                 [alert show];
                                                             }
                                                             else
                                                             {
                                                                 Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
                                                                 [flowController updateUserProfileWithCompletion:^(BOOL success, NSError *error) {
                                                                     OrderProcessedViewController *processOrder = [self.storyboard instantiateViewControllerWithIdentifier:@"processOrderView"];
                                                                     [processOrder setProduct:self.product];
                                                                     processOrder.parent = self;
                                                                     [self presentViewController:processOrder animated:NO completion:nil];
                                                                     
                                                                     [self.hud hideAnimated:YES];
                                                                 }];
                                                            
                                                             }
                                                         }];
        }
    }];
}

-(void)updateAddressWithType:(Li5AddressType)type completion:(void (^)(NSError *error))completion {
   
    [[Li5ApiHandler sharedInstance] updateUserWihAddress:self.address.text zipCode:self.zipCode.text city:self.city.text state:self.state country:self.country type:type alias: @"" completion:^(NSError *error) {
    
        if (error)
        {
            [self.hud hideAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            completion(nil);
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
        DDLogVerbose(@"Found placemarks: %u, error: %@", placemarks.count, error);
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
    [self.map setShowsUserLocation:false];
    self.address.text = [NSString stringWithFormat:@"%@ %@",placemark.subThoroughfare, placemark.thoroughfare];
    self.city.text = placemark.locality;
    self.zipCode.text = placemark.postalCode;
    self.state = placemark.administrativeArea;
    self.country = placemark.country;
    
    [self.map removeAnnotations:self.map.annotations];
    self.shippingAddressMark = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:placemark.addressDictionary];
//    if (!userLocation)
//    {
        [self.map addAnnotation:self.shippingAddressMark];
        [self.map showAnnotations:@[self.shippingAddressMark] animated:YES];
//    }
//    else
//    {
//        [self.map showAnnotations:@[self.map.userLocation] animated:YES];
//    }
    
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


- (void)generateStripeTokenWithParams:(STPCardParams *)cardParams completion:(void (^)(STPToken *token, NSError *error))completion
{
    [[STPAPIClient sharedClient] createTokenWithCard:cardParams completion:^(STPToken *token, NSError *error) {
        if (error) {
            // show the error, maybe by presenting an alert to the user
            DDLogError(@"error while validating card: %@", error.localizedDescription);
            completion(nil, error);
        } else {
            if (completion!=nil)
            {
                completion(token, nil);
            }
        }
    }];
}

- (STPCardParams*)getTestingCard
{
    STPCardParams *cardParams = [[STPCardParams alloc] init];
    cardParams.number = @"4242 4242 4242 4242";
    cardParams.expMonth = 12;
    cardParams.expYear = 2021;
    cardParams.cvc = @"1234";
    cardParams.name = @"Robert B Cool";
    return cardParams;
}

@end
