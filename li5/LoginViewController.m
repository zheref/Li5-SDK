//
//  InitialViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "LoginViewController.h"
#import "Li5ApiHandler.h"
#import "RootViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //DDLogVerbose(@"Finished loading InitialViewController");
    
    //Add background image
    UIImage* backgroundImage = [UIImage imageNamed:@"girl.jpg"];
    CALayer* aLayer = [CALayer layer];
    CGRect startFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    aLayer.contents = (id)backgroundImage.CGImage;
    aLayer.frame = startFrame;
    
    [self.view.layer addSublayer:aLayer];

    //only apply the blur if the user hasn't disabled transparency effects
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:blurEffectView];
    }

    UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(0,25,self.view.frame.size.width,200)];
    [appName setTextColor:[UIColor whiteColor]];
    [appName setNumberOfLines:0];
    [appName setFont:[UIFont fontWithName:@"Avenir-Black" size:28]];
    [appName setTextAlignment: NSTextAlignmentCenter];
    appName.text = @"Li5";
    
    [self.view addSubview:appName];
    
    UILabel *appTagline = [[UILabel alloc] initWithFrame:CGRectMake(50,150,self.view.frame.size.width - 100,200)];
    [appTagline setTextColor:[UIColor whiteColor]];
    [appTagline setNumberOfLines:0];
    [appTagline setFont:[UIFont fontWithName:@"Avenir" size:22]];
    [appTagline setTextAlignment: NSTextAlignmentCenter];
    appTagline.text = @"Discover Original Products introduced by People like you everyday.";
    
    [self.view addSubview:appTagline];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    loginButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 100);
    loginButton.readPermissions = @[@"public_profile", @"email"];
    loginButton.delegate = self;
    [self.view addSubview:loginButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) enterAction: (UITapGestureRecognizer *)gestureRecognizer {
    //DDLogVerbose(@"Login Button tapped");
    
    //Extend to frame bounds
    [UIView animateWithDuration:0.5 animations:^{
        [((UIButton*)gestureRecognizer.view) setTitle:@"" forState:UIControlStateNormal];
        gestureRecognizer.view.frame = CGRectMake(-5,-5,self.view.frame.size.width+10,self.view.frame.size.height+10);
    } completion:^(BOOL finished) {
        RootViewController *rootViewController = [[RootViewController alloc] init];
        [self.navigationController pushViewController:rootViewController animated:NO];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (error == nil) {
        DDLogVerbose(@"FB Token: %@", FBSDKAccessToken.currentAccessToken.tokenString);
        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"id, name, email" forKey:@"fields"];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,id result, NSError *error) {
             if (error == nil) {
                 DDLogVerbose(@"Mail: %@", [(NSDictionary *)result objectForKey:@"email"]);
                 Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
                 [li5 login:[(NSDictionary *)result objectForKey:@"email"] withFacebookToken:FBSDKAccessToken.currentAccessToken.tokenString withCompletion:^(NSError *error) {
                     if (error == nil) {
                         UIViewController *initialController = [[RootViewController alloc] init];
                         [self.navigationController pushViewController:initialController animated:FALSE];
                     } else {
                         DDLogVerbose(@"Couldn't login with Facebook: %@", error.localizedDescription);
                     }
                 }];
             } else {
                 DDLogVerbose(@"Error when fetching email: %@", error);
             }
         }];
    } else {
        DDLogVerbose(@"Couldn't login: %@", error);
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}

//- (BOOL)loginButtonWillLogin:(FBSDKLoginButton *)loginButton {
//    
//}

@end
