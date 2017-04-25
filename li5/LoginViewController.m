//
//  InitialViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/25/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import Li5Api;
@import MMMaterialDesignSpinner;
@import FXBlurView;
@import AVFoundation;
@import DigitsKit;
@import Crashlytics;

#import "LoginViewController.h"
#import "Li5Constants.h"
#import <Heap/Heap.h>

@interface LoginViewController ()
{
    id playEndObserver;
}

@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *loginFacebookButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *videoLayer;
@property (nonatomic, assign) BOOL viewAppeared;
@property (weak, nonatomic) IBOutlet UIButton *loginWithPhoneNumber;

@property (nonatomic, assign) CGPoint originalLogoPosition;
@property (nonatomic, assign) BOOL animationsSetupAlready;

@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"onboarding_3" ofType:@"mp4"]]];
    _player.muted = YES;
    _videoLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    _videoLayer.frame = self.view.bounds;
    _videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.backgroundView.layer addSublayer:_videoLayer];
    
    // Handle clicks on the button
    [_loginFacebookButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewWillAppear:animated];
    
    _viewAppeared = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    [self readyToPlay];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
    
    [self.player pause];
    [self removeObservers];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!_animationsSetupAlready)
    {
        _originalLogoPosition = self.logoView.layer.position;
        _animationsSetupAlready = true;
    }
    
    self.logoView.layer.position = _originalLogoPosition;
}


- (CGPoint)logoPosition
{
    return self.logoView.layer.position;
}

#pragma mark - Player Delegate

- (void)readyToPlay
{
    DDLogVerbose(@"");
    if (/*self.player.status == AVPlayerStatusReadyToPlay &&*/ self.viewAppeared)
    {
        [self.player play];
        [self setupObservers];
    }
}

- (void)failToLoadItem:(NSError *)error
{
    DDLogVerbose(@"");
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
}

- (void)bufferReady
{
    DDLogVerbose(@"");
}

- (void)networkFail:(NSError *)error
{
    DDLogError(@"");
    [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
}

- (void)replay
{
    DDLogVerbose(@"");
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)removeObservers
{
    if (playEndObserver)
    {
        DDLogVerbose(@"");
        [[NSNotificationCenter defaultCenter] removeObserver:playEndObserver];
        playEndObserver = nil;
    }
}

- (void)setupObservers
{
    if (!playEndObserver)
    {
        DDLogVerbose(@"");
        __weak typeof(id) welf = self;
        playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf replay];
        }];
    }
}

#pragma mark - FBSDKLoginButtonDelegate

- (IBAction)loginWithPhoneNumber:(id)sender {
    DGTAuthenticationConfiguration *configuration = [[DGTAuthenticationConfiguration alloc] initWithAccountFields:DGTAccountFieldsEmail];
    configuration.appearance = [self makeTheme];
    [[Digits sharedInstance] authenticateWithViewController:nil configuration:configuration completion:^(DGTSession *session, NSError *error) {
        if (session) {
            // TODO: associate the session userID with your user model
            DDLogVerbose(@"Mail: %@ - Phone Number: %@", session.emailAddress, session.phoneNumber);
            
            DGTOAuthSigning *oauthSigning = [[DGTOAuthSigning alloc] initWithAuthConfig:[Digits sharedInstance].authConfig authSession:session];
            
            NSDictionary *authHeaders = [oauthSigning OAuthEchoHeadersToVerifyCredentials];
            NSString *authProvider = [authHeaders objectForKey:TWTROAuthEchoRequestURLStringKey];
            NSString *verificationCredential = [authHeaders objectForKey:TWTROAuthEchoAuthorizationHeaderKey];
            
            if (!(authProvider.length > 0 && verificationCredential.length > 0)) {
                DDLogError(@"Error pulling oAuth Echo tokens");
                
                [self logAndDisplayError:error userInfo:session];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
                
                [li5 login:session.emailAddress withDigitsAuthServiceProvider:authProvider andCredentialsAuthorization:verificationCredential withCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error == nil)
                        {
                            DDLogInfo(@"Successfully logged in into Li5");
                                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                                [notificationCenter postNotificationName:kLoginSuccessful object:nil];
                            
                        }
                        else
                        {
                            DDLogError(@"Couldn't login into Li5 with Digits: %@", error.localizedDescription);
                            
                            [self logAndDisplayError:error userInfo:session];
                        }
                    });
                }];
            });
            
        } else if (error && error.code != 1) {
            DDLogError(@"Error when fetching phone + email: %@", error.localizedDescription);
            
            [self logAndDisplayError:error userInfo:error];
        }
    }];
}

- (void)logAndDisplayError:(NSError*)err userInfo:(id)userObj {
    [self logAndDisplayError:err userInfo:userObj showSettingsActions:NO];
}

- (void)logAndDisplayError:(NSError*)err userInfo:(id)userObj showSettingsActions:(BOOL)showSettingsAction {
    
    [[CrashlyticsLogger sharedInstance] logError:err userInfo:userObj];
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if (err!=nil) [properties setObject:err forKey:@"error"];
    if (userObj!=nil) [properties setObject:userObj forKey:@"userInfo"];
    [Heap track:@"Error while Login" withProperties:properties];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"There was an error with your request. Please try again later. (%@)",nil),err.localizedDescription];
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error",nil)
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    if (showSettingsAction) {
        UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings",nil) style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                               }];
        
        [alert addAction:settingsAction];
    }
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (DGTAppearance *)makeTheme {
    DGTAppearance *theme = [[DGTAppearance alloc] init];
    theme.bodyFont = [UIFont fontWithName:@"Rubik-Regular" size:26];
    theme.labelFont = [UIFont fontWithName:@"Rubik-Regular" size:17];
    theme.accentColor = [UIColor li5_whiteColor];
    theme.backgroundColor = [UIColor li5_redColor];
    return theme;
}


// Once the button is clicked, show the login dialog
- (void)loginButtonClicked
{
    DDLogVerbose(@"");

    // Initialize the progress view
    _spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:self.loginFacebookButton.frame];
    _spinnerView.lineWidth = 3.5f;
    _spinnerView.tintColor = [UIColor li5_whiteColor];
    _spinnerView.hidesWhenStopped = YES;
    [self.overlayView addSubview:_spinnerView];
    [_spinnerView startAnimating];
    [self.loginFacebookButton setHidden:YES];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    login.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    [login logInWithReadPermissions:@[ @"public_profile", @"email", @"user_location", @"user_birthday" ]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                              [self didCompleteWithResult:result error:error];
                            }];
}

- (void)didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    DDLogVerbose(@"");
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
                  
                [welf.spinnerView stopAnimating];
                  
                if (error == nil)
                {
                    DDLogInfo(@"Successfully logged in into Li5");
                    
                    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration];
                    
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:kLoginSuccessful object:nil];
                }
                else
                {
                    DDLogError(@"Couldn't login into Li5 with Facebook: %@", error.localizedDescription);
                    
                    [welf.loginFacebookButton setHidden:NO];
                    
                    [self logAndDisplayError:error userInfo:result];
                }
              }];
          }
          else
          {
              DDLogError(@"Error when fetching email: %@", error.localizedDescription);
              
              [welf.spinnerView stopAnimating];
              [welf.loginFacebookButton setHidden:NO];
              
              [self logAndDisplayError:error userInfo:result];
          }
        }];
    }
    else
    {
        DDLogError(@"Couldn't login: %@", error);
        
        [self logAndDisplayError:error userInfo:result showSettingsActions:YES];
        
        [welf.spinnerView stopAnimating];
        [welf.loginFacebookButton setHidden:NO];
    }
}

- (IBAction)loadTos:(id)sender {
    
    UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"tosVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
