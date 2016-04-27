//
//  RootViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "RootViewController.h"
#import "Li5ApiHandler.h"
#import "CategoriesViewController.h"
#import "PrimeTimeViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation RootViewController

- (instancetype)init
{
    //DDLogVerbose(@"initializing RootController");
    self = [super init];
    if (self) {
        if (FBSDKAccessToken.currentAccessToken != nil)
        {
            __weak typeof(self) welf = self;
            [self requestUserProfileWithCompletion:^(NSError *profileError, Profile *profile) {
                if ( profileError != nil )
                {
                    DDLogError(@"Error while requesting Profile %@", profileError.description);
                    //Logging out user - force them to log in again
                    [FBSDKAccessToken setCurrentAccessToken:nil];
                    [welf renderError:profileError];
                } else {
                    DDLogInfo(@"Profile requested successfully");
                    BOOL showCategoriesSelection = [profile.preferences.data count] < 2;
                    
                    UIViewController *nextViewController = ( showCategoriesSelection ?
                                                            [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:[NSBundle mainBundle]] : [[PrimeTimeViewController alloc] init]);
                    
                    [self.navigationController pushViewController:nextViewController animated:NO];

                }
            }];
        } else {
            DDLogVerbose(@"User not logged in");
        }
    }
    return self;
}

- (void)viewDidLoad {
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

- (void)requestUserProfileWithCompletion:(void (^)(NSError *error, Profile *profile)) completion {
    
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 requestProfile:^(NSError *error, Profile *profile) {
        completion(error,profile);
    }];
    
}

#pragma mark - Pages

- (void) renderError:(NSError *) error
{
    //Stop spinner
    [[self.view viewWithTag:12] stopAnimating];
    
    NSString *errorMessage = @"There was a problem requesting your query. Please try again in a minute!";
    UIFont *errorMessageFont = [UIFont fontWithName:@"Avenir" size:14];
    CGRect errorMessageSize = [errorMessage boundingRectWithSize:CGSizeMake(self.view.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:errorMessageFont} context:nil];
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,self.view.center.y,errorMessageSize.size.width,errorMessageSize.size.height)];
    errorLabel.center = self.view.center;
    [errorLabel setTextColor:[UIColor whiteColor]];
    [errorLabel setNumberOfLines:0];
    [errorLabel setFont:errorMessageFont];
    [errorLabel setText:errorMessage];
    [errorLabel setTextAlignment: NSTextAlignmentCenter];
    [self.view addSubview:errorLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
