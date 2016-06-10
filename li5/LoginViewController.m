//
//  InitialViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "LoginViewController.h"
#import "RootViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *loginFacebookButton;

@end

@implementation LoginViewController

@dynamic pageIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _overlayView.backgroundColor = [[UIColor li5_redColor] colorWithAlphaComponent:0.80];

    // Handle clicks on the button
    [_loginFacebookButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - FBSDKLoginButtonDelegate

// Once the button is clicked, show the login dialog
- (void)loginButtonClicked
{
    self.view.userInteractionEnabled = NO;
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    login.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    [login logInWithReadPermissions:@[ @"public_profile", @"email" ]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                              [self didCompleteWithResult:result error:error];
                            }];
}

- (void)didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    __weak typeof(self) welf = self;
    if (error == nil)
    {
        DDLogInfo(@"Successfully logged in with Facebook");
        DDLogVerbose(@"FB Token: %@", FBSDKAccessToken.currentAccessToken.tokenString);
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"id, name, email" forKey:@"fields"];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
          if (error == nil)
          {
              DDLogVerbose(@"Mail: %@", [(NSDictionary *)result objectForKey:@"email"]);
              Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
              [li5 login:[(NSDictionary *)result objectForKey:@"email"] withFacebookToken:FBSDKAccessToken.currentAccessToken.tokenString withCompletion:^(NSError *error) {
                if (error == nil)
                {
                    DDLogInfo(@"Successfully logged in into Li5");
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:@"LoginSuccessful" object:nil];
                }
                else
                {
                    DDLogVerbose(@"Couldn't login into Li5 with Facebook: %@", error.localizedDescription);
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:@"LoginUnsuccessful" object:nil];
                }
                welf.view.userInteractionEnabled = YES;
              }];
          }
          else
          {
              DDLogVerbose(@"Error when fetching email: %@", error);
              NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
              [notificationCenter postNotificationName:@"LoginUnsuccessful" object:nil];
          }
          welf.view.userInteractionEnabled = YES;
        }];
    }
    else
    {
        DDLogVerbose(@"Couldn't login: %@", error);
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"LoginUnsuccessful" object:nil];
    }
    self.view.userInteractionEnabled = YES;
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 clearAccessToken];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
