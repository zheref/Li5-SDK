//
//  ProfileShippingInfoViewController.m
//  li5
//
//  Created by gustavo hansen on 10/17/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "AppDelegate.h"
#import "Li5RootFlowController.h"
#import "Li5ApiHandler.h"

#import "ProfileShippingInfoViewController.h"
#import "AddShippingInfoViewController.h"

@import MapKit;
@import MBProgressHUD;
@import Li5Api;

@interface ProfileShippingInfoViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *shippingAddressMark;

@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *stateText;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeText;
@property (weak, nonatomic) IBOutlet UIButton *LocationBtn;
@property (weak, nonatomic) IBOutlet UITextField *cityText;

@property  (nonatomic, strong) Address * currentAddres;

@property NSArray<Address *> *addresses;

@end

@implementation ProfileShippingInfoViewController

- (void)viewDidLoad {
    DDLogVerbose(@"");
    
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    Profile *userProfile = [flowController userProfile];
    
    self.map.zoomEnabled = false;
    self.map.scrollEnabled = false;
    self.map.userInteractionEnabled = false;
    
    if(userProfile) {
        
        [self setAddressValues:userProfile.defaultAddress];
    }
    
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    self.navigationItem.rightBarButtonItem = edit;
    
    
    UIBarButtonItem *back =  [[UIBarButtonItem alloc] initWithImage:[UIImage
                                                                     imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self
                                                             action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = back;
    
    
    self.currentAddres = userProfile.defaultAddress;
}

-(void)edit {
    
    
    AddShippingInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingInfoVC"];
    
    [vc setCurrentAddress:self.currentAddres];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)setAddressValues:(Address *) address{
    
    self.currentAddres = address;
    self.address.text = address.address1;
    self.cityText.text = address.city;
    self.stateText.text = address.state;
    self.postalCodeText.text = address.zip;
    
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = [@"Shipping Info" uppercaseString];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [[Li5ApiHandler sharedInstance] requestUserAddressesWithCompletion:^(NSError *error, NSArray<Address *> *addresses) {
        
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
            
            if(addresses.count == 0) {
                [self goBack:nil];
            }else {
                self.addresses = addresses;
            }
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addShippingAddress:(id)sender {
}

- (IBAction)goBack:(id)sender {
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        if([controller.restorationIdentifier isEqualToString:@"userSettingsVC"]){
            
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (IBAction)changeLocation:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Select a Default Location"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (Address *address in self.addresses) {
        
        NSString *alias = address.alias ? address.alias : address.address1;
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: [NSString stringWithFormat: @"%@",  alias]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self handleAddressChange:address];
                                                       }];
        
        if(_currentAddres.id == address.id){
        
            [action setValue:[UIImage imageNamed:@"check.png"] forKey:@"_image"];
        }
        
        [alert addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel"
                                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                         
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         //TODO get card info
                                                     }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)handleAddressChange:(Address *) address {
    
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    [flowController updateUserProfile];
    
    [self setAddressValues:address];
    
    
}

- (IBAction)addShippingInfo:(id)sender {
    AddShippingInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingInfoVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
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
