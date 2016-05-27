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

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //DDLogVerbose(@"Finished loading InitialViewController");

    //Add background image
    UIImage *backgroundImage = [UIImage imageNamed:@"girl.jpg"];
    CALayer *aLayer = [CALayer layer];
    CGRect startFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    aLayer.contents = (id)backgroundImage.CGImage;
    aLayer.frame = startFrame;

    [self.view.layer addSublayer:aLayer];

    //only apply the blur if the user hasn't disabled transparency effects
    if (!UIAccessibilityIsReduceTransparencyEnabled())
    {
        self.view.backgroundColor = [UIColor clearColor];

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view addSubview:blurEffectView];
    }

    UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.view.frame.size.width, 200)];
    [appName setTextColor:[UIColor whiteColor]];
    [appName setNumberOfLines:0];
    [appName setFont:[UIFont fontWithName:@"Avenir-Black" size:28]];
    [appName setTextAlignment:NSTextAlignmentCenter];
    appName.text = @"Li5";

    [self.view addSubview:appName];

    UILabel *appTagline = [[UILabel alloc] initWithFrame:CGRectMake(50, 150, self.view.frame.size.width - 100, 200)];
    [appTagline setTextColor:[UIColor whiteColor]];
    [appTagline setNumberOfLines:0];
    [appTagline setFont:[UIFont fontWithName:@"Avenir" size:22]];
    [appTagline setTextAlignment:NSTextAlignmentCenter];
    appTagline.text = @"Discover Original Products introduced by People like you everyday.";

    [self.view addSubview:appTagline];

    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    loginButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 100);
    loginButton.readPermissions = @[ @"public_profile", @"email" ];
    loginButton.delegate = self;
    [self.view addSubview:loginButton];
}

#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
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
                }
              }];
          }
          else
          {
              DDLogVerbose(@"Error when fetching email: %@", error);
          }
        }];
    }
    else
    {
        DDLogVerbose(@"Couldn't login: %@", error);
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
}

//- (BOOL)loginButtonWillLogin:(FBSDKLoginButton *)loginButton {
//
//}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
