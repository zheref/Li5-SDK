//
//  AddShippingInfoViewController.m
//  li5
//
//  Created by gustavo hansen on 10/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import MapKit;
@import MBProgressHUD;
@import Li5Api;

#import "AddShippingInfoViewController.h"
#import "Li5RootFlowController.h"
#import "AppDelegate.h"

@interface AddShippingInfoViewController ()
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

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationBtn;
@property (weak, nonatomic) IBOutlet UITextField *alias;

@property (nonatomic, strong, setter=setCurrentAddress:) Address *currentAddress;
@property (strong, nonatomic, setter=setCreditCardParams:) STPCardParams *cardParams;
@property (weak, nonatomic,setter=setCreditCardAlias:) NSString *cardAlias;
@end

@implementation AddShippingInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    
    [self.currentLocationBtn setImage:[[UIImage imageNamed:@"currentLocation"] blackAndWhiteImage] forState:UIControlStateNormal];
    [self.currentLocationBtn setImage:[UIImage imageNamed:@"currentLocation"] forState:UIControlStateHighlighted];
    
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] andRect:self.view.bounds] forState:UIControlStateDisabled];
    [self.saveBtn setEnabled:NO];
    
    if ([CLLocationManager locationServicesEnabled])
    {
        if (!_locationManager)
        {
            _locationManager = [[CLLocationManager alloc] init];
            
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = 10.0;
        }
        
        if (!_geocoder)
        {
            _geocoder = [[CLGeocoder alloc] init];
        }
    }
    
    if(_currentAddress != nil) {
        [self setAddressValues:_currentAddress];
        
        UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(delete)];
        self.navigationItem.rightBarButtonItem = delete;
    }
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    
    keyboardToolbar.items = @[spaceItem,doneItem];
    [keyboardToolbar sizeToFit];
    
    self.alias.inputAccessoryView = keyboardToolbar;
}

- (void)done:(id)sender
{
    DDLogVerbose(@"%@",sender);
    [self.alias resignFirstResponder];
}

- (void)delete {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [[Li5ApiHandler sharedInstance] deleteAddress:_currentAddress completion:^(NSError *error) {
        [hud hideAnimated:YES];
        
        if (error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.description
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
        }else {
            [self goBackToRoot:true];
        }
    }];
}

-(void)goBackToRoot:(BOOL)returnToShpping {

    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    [flowController updateUserProfile];
    
//    NSString *controllerString = returnToShpping ? @"shippingEmptyVC" : @"paymentEmptyVC";
//    
//    for (UIViewController *controller in self.navigationController.viewControllers) {
//    
//        if([controller.restorationIdentifier isEqualToString:controllerString]){
//      
//            [self.navigationController popToViewController:controller animated:YES];
//        }
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setCurrentAddress:(Address *)address {
    _currentAddress = address;
}

- (void)didReceiveMemoryWarning {
    DDLogVerbose(@"");
    
    [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
    
    [self.map removeFromSuperview];
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


- (void)setAddressValues:(Address *) address{
    
    self.address.text = address.address1;
    self.city.text = address.city;
    self.state = address.state;
    self.zipCode.text = address.zip;
    
    NSString *location = [NSString stringWithFormat:@"%@, %@ and %@",
                          address.address1, address.state, address.zip];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     
                     [self.map removeAnnotations:self.map.annotations];
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateRegion region = self.map.region;
                         region.center =  placemark.location.coordinate;
                         region.span.longitudeDelta = 0.1;
                         region.span.latitudeDelta =  0.1;
                         
                         [self.map setRegion:region animated:YES];
                         [self.map addAnnotation:placemark];
                         
                         [self.map addAnnotation:placemark];
                         
                         [self.map showAnnotations:@[placemark] animated:YES];
                     }
                 }
     ];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(_cardParams != nil) {
        self.title = [@"Billing Address" uppercaseString];
    }
    else {
        self.title = [@"Shipping Info" uppercaseString];
    }
}

-(void)setCreditCardAlias:(NSString *)value {

    _cardAlias = value;
}
- (IBAction)save:(id)sender
{
    DDLogVerbose(@"");
    
    if(_cardParams == nil || _currentAddress != nil) {
        
    [self updateAddressWithType:Li5AddressTypeBilling completion:^(NSError *error) {
        
         [self goBackToRoot:true];
    }];
    }
    else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        
#if DEBUG
        _cardParams = [self getTestingCard];
#endif
        
        _cardParams.addressZip = self.zipCode.text;
        _cardParams.addressCity = self.city.text;
        _cardParams.addressState = self.state;
        _cardParams.addressCountry = self.country;
        _cardParams.addressLine1 = self.address.text;
        
        [self generateStripeTokenWithParams:_cardParams completion:^(STPToken *token, NSError *error) {
            if (error)
            {
                [hud hideAnimated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:error.description
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                
                [[Li5ApiHandler sharedInstance] updateUserWihCreditCard:token.tokenId
                                                                  alias: _cardAlias
                                                             completion:^(NSError *error) {
                                                                 
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
                                                                     [self goBackToRoot:false];
                                                                 }
                                                             }];
            }
        }];
    
    }
}

-(void)updateAddressWithType:(Li5AddressType)type completion:(void (^)(NSError *error))completion {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [[Li5ApiHandler sharedInstance] updateUserWihAddress:self.address.text zipCode:self.zipCode.text city:self.city.text state:self.state country:self.country type:type alias:self.alias.text completion:^(NSError *error) {
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
        DDLogVerbose(@"Found placemarks: %lu, error: %@", placemarks.count, error);
        if (error == nil && [placemarks count] > 0) {
            [self.map removeAnnotations:self.map.annotations];
            
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
    [self.saveBtn setEnabled:(self.address.text.length != 0 && self.city.text.length != 0 && self.zipCode.text.length != 0 && self.state.length != 0 && self.country.length != 0)];
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
