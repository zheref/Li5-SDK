//
//  InitialViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;
@import MMMaterialDesignSpinner;
@import FXBlurView;
@import AVFoundation;

#import "LoginViewController.h"
#import "Li5Constants.h"

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
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:kLoginSuccessful object:nil];
                }
                else
                {
                    DDLogError(@"Couldn't login into Li5 with Facebook: %@", error.localizedDescription);
                    [welf.loginFacebookButton setHidden:NO];
                }
              }];
          }
          else
          {
              DDLogError(@"Error when fetching email: %@", error);
              
              [welf.spinnerView stopAnimating];
              [welf.loginFacebookButton setHidden:NO];
          }
        }];
    }
    else
    {
        DDLogError(@"Couldn't login: %@", error);
        
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
