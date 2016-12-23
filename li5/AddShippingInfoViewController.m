//
//  AddShippingInfoViewController.m
//  li5
//
//  Created by gustavo hansen on 10/18/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import MapKit;
@import MBProgressHUD;
@import Li5Api;

#import "AddShippingInfoViewController.h"
#import "Li5RootFlowController.h"
#import "AppDelegate.h"

@interface AddShippingInfoViewController () <UITextFieldDelegate>
{
    BOOL __userLocationShown;
}

@property (weak, nonatomic) IBOutlet UILabel *aliasLabel;
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
@property int keyboardHeight;
@property BOOL isAliasTextFieldBeingEdited;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveUpView:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    self.alias.delegate = self;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
        
        
        if (error)
        {
            [hud hideAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
        }else {
            [self goBackToRoot:true hud:hud];
        }
    }];
}

-(void)goBackToRoot:(BOOL)returnToShipping hud:(MBProgressHUD *)hud {
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    [flowController updateUserProfileWithCompletion:^(BOOL success, NSError *error) {
        
        [hud hideAnimated:YES];
        
        if(returnToShipping) {
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else {
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                
                if([controller.restorationIdentifier isEqualToString:@"paymentInfoSelectVC"]){
                    
                    [self.navigationController popToViewController:controller animated:YES];
                    
                    return;
                }
            }
        }
    }];
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


- (void)setAddressValues:(Address *) address{
    
    self.address.text = address.address1;
    self.city.text = address.city;
    self.state = address.state;
    self.zipCode.text = address.zip;
    self.alias.text = address.alias;
    NSString *location = [NSString stringWithFormat:@"%@, %@ and %@",
                          address.address1, address.state, address.zip];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     
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
        self.alias.hidden = true;
        self.aliasLabel.hidden = true;
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    if(_cardParams == nil || _currentAddress != nil) {
        
        [self updateAddressWithType:Li5AddressTypeBilling completion:^(NSError *error) {
            
            [self goBackToRoot:true hud:hud];
        }];
    }
    else {
        
//#if DEBUG
//        _cardParams = [self getTestingCard];
//#endif
        
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
                                                                message:error.localizedDescription
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
                                                                 
                                                                 
                                                                 if (error)
                                                                 {
                                                                     [hud hideAnimated:YES];
                                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                                     message:error.localizedDescription
                                                                                                                    delegate:self
                                                                                                           cancelButtonTitle:@"OK"
                                                                                                           otherButtonTitles:nil];
                                                                     [alert show];
                                                                 }
                                                                 else
                                                                 {
                                                                     [self goBackToRoot:false hud:hud];
                                                                 }
                                                             }];
            }
        }];
        
    }
}

-(void)updateAddressWithType:(Li5AddressType)type completion:(void (^)(NSError *error))completion {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    if(_currentAddress.id) {
        
        _currentAddress.address1 = self.address.text;
        _currentAddress.zip = self.zipCode.text;
        _currentAddress.city = self.city.text;
        _currentAddress.state = self.state;
        _currentAddress.country = self.country;
        _currentAddress.alias = self.alias.text;
        
        [[Li5ApiHandler sharedInstance] updateAddress:_currentAddress completion:^(NSError *error) {
            [hud hideAnimated:YES];
            if (error)
            {
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
    } else {
        [[Li5ApiHandler sharedInstance] updateUserWihAddress:self.address.text zipCode:self.zipCode.text city:self.city.text state:self.state country:self.country type:type alias:self.alias.text completion:^(NSError *error) {
            [hud hideAnimated:YES];
            if (error)
            {
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
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    DDLogVerbose(@"");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 1) {
        _isAliasTextFieldBeingEdited = false;
        [self animate: NO];
    }else {
        DDLogVerbose(@"");
        NSString *newAddress = textField.text;
        [self.geocoder geocodeAddressString:newAddress completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            DDLogVerbose(@"Found placemarks: %u, error: %@", placemarks.count, error);
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
    [self.map setShowsUserLocation:false];
    [self.currentLocationBtn setHighlighted:YES];
    
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
//        if(self.map.userLocation != nil) {
//            
//            [self.map showAnnotations:@[self.map.userLocation] animated:YES];
//        }
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


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1) {
        _isAliasTextFieldBeingEdited = true;
    }
}

- (void) animate: (BOOL) up
{
    if(up) {
        self.view.frame = [UIScreen mainScreen].bounds;
    }
    
    const int movementDistance = _keyboardHeight;
    const float movementDuration = 0.1f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)moveUpView:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    _keyboardHeight = keyboardFrameBeginRect.size.height;
    
    if(_isAliasTextFieldBeingEdited) {
        [self animate:YES];
    }
}

@end
