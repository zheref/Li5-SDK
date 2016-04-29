//
//  RootViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "CategoriesViewController.h"
#import "Li5ApiHandler.h"
#import "LoginViewController.h"
#import "PrimeTimeViewController.h"
#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (instancetype)init
{
    DDLogVerbose(@"initializing RootController");
    self = [super init];
    if (self)
    {
        [self requestUserProfileWithCompletion:^(NSError *profileError, Profile *profile) {
          //If anything, take the user back to login as default
          UIViewController *nextViewController = [[LoginViewController alloc] init];
          if (profileError != nil)
          {
              DDLogError(@"Error while requesting Profile %@", profileError.description);
              //Logging out user - force them to log in again
              [FBSDKAccessToken setCurrentAccessToken:nil];
          }
          else
          {
              DDLogInfo(@"Profile requested successfully");
              BOOL showCategoriesSelection = [profile.preferences.data count] < 2;

              nextViewController = (showCategoriesSelection ? [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:[NSBundle mainBundle]] : [[PrimeTimeViewController alloc] init]);
          }

          [self.navigationController pushViewController:nextViewController animated:NO];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //DDLogVerbose(@"Loading RootViewController");

    [self.view setBackgroundColor:[UIColor redColor]];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

#pragma mark - App Flow

- (void)requestUserProfileWithCompletion:(void (^)(NSError *error, Profile *profile))completion
{
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 requestProfile:^(NSError *error, Profile *profile) {
      completion(error, profile);
    }];
}

#pragma mark - Pages

- (void)renderError:(NSError *)error
{
    //Stop spinner
    [[self.view viewWithTag:12] stopAnimating];

    NSString *errorMessage = @"There was a problem requesting your query. Please try again in a minute!";
    UIFont *errorMessageFont = [UIFont fontWithName:@"Avenir" size:14];
    CGRect errorMessageSize = [errorMessage boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : errorMessageFont } context:nil];
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.center.y, errorMessageSize.size.width, errorMessageSize.size.height)];
    errorLabel.center = self.view.center;
    [errorLabel setTextColor:[UIColor whiteColor]];
    [errorLabel setNumberOfLines:0];
    [errorLabel setFont:errorMessageFont];
    [errorLabel setText:errorMessage];
    [errorLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:errorLabel];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
