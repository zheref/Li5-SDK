//
//  RootViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import AVFoundation;

#import "CategoriesViewController.h"
#import "LoginViewController.h"
#import "PrimeTimeViewController.h"
#import "RootViewController.h"
#import "OnboardingViewController.h"

#import "UserProductsCollectionViewDataSource.h"

@interface RootViewController ()
{
    AVPlayerLayer *loadingLayer;
    id playEndObserver;
}

@end

@implementation RootViewController

#pragma mark - Init

- (instancetype)init
{
    DDLogVerbose(@"initializing RootController");
    self = [super init];
    if (self)
    {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(flow)
                                   name:@"LoginSuccessful"
                                 object:nil];

        [notificationCenter addObserver:self
                               selector:@selector(flow)
                                   name:@"LogoutSuccessful"
                                 object:nil];
    }
    return self;
}

#pragma mark - UI Setup

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DDLogVerbose(@"");
    
    NSString *loadingPath = [[NSBundle mainBundle] pathForResource:@"logo_loading" ofType:@"mp4"];
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:loadingPath]];
    loadingLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    loadingLayer.frame = self.view.bounds;
    loadingLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:loadingLayer];
    
    [self flow];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [loadingLayer.player play];
    
    [self setupVideoEndObservers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [loadingLayer.player pause];
    
    [self removeVideoEndObservers];
}

- (void)replayMovie:(NSNotification *)notification
{
    DDLogVerbose(@"replaying animation");
    [loadingLayer.player seekToTime:kCMTimeZero];
    [loadingLayer.player play];
}

- (void)setupVideoEndObservers
{
    if (!playEndObserver)
    {
        __weak typeof(id) welf = self;
        playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:loadingLayer.player.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf replayMovie:note];
        }];
    }
}

- (void)removeVideoEndObservers
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:loadingLayer.player.currentItem];
    playEndObserver = nil;
}

#pragma mark - App Actions

- (void)flow
{
    // Do any additional setup after loading the view.
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    if (!FBSDKAccessToken.currentAccessToken)
    {
        [self.navigationController pushViewController:[[OnboardingViewController alloc] init] animated:NO];
    }
    else
    {
        [li5 requestProfile:^(NSError *profileError, Profile *profile) {
            //If anything, take the user back to login as default
            UIViewController *nextViewController = [[OnboardingViewController alloc] init];
            if (profileError != nil)
            {
                DDLogError(@"Error while requesting Profile %@", profileError.description);
                //Logging out user - force them to log in again
                [FBSDKAccessToken setCurrentAccessToken:nil];
                [self.navigationController pushViewController:nextViewController animated:NO];
            }
            else
            {
                DDLogInfo(@"Profile requested successfully");
                BOOL showCategoriesSelection = [profile.preferences.data count] < 2;
                
                if (showCategoriesSelection)
                {
                    nextViewController = [[CategoriesViewController alloc] init];
                    [self.navigationController pushViewController:nextViewController animated:NO];
                }
                else
                {
//                    PrimeTimeViewControllerDataSource *primeTimeSource = [UserProductsCollectionViewDataSource new];
                    PrimeTimeViewControllerDataSource *primeTimeSource = [PrimeTimeViewControllerDataSource new];
                    PrimeTimeViewController *primeTimeVC = [[PrimeTimeViewController alloc] initWithDataSource:primeTimeSource];
                    [primeTimeSource startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
                        if (error != nil)
                        {
                            DDLogVerbose(@"ERROR %@", error.description);
                        }
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [loadingLayer.player pause];
                            [loadingLayer.player replaceCurrentItemWithPlayerItem:nil];
                            [loadingLayer removeFromSuperlayer];
                            loadingLayer = nil;
                            
                            [self.navigationController pushViewController:primeTimeVC animated:NO];
                        });
                    }];
                }
            }
        }];
    }
}

#pragma mark - OS Actions

- (void)dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    playEndObserver = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
