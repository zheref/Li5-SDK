//
//  RootViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "CategoriesViewController.h"
#import "Li5RootFlowController.h"
#import "LoginViewController.h"
#import "OnboardingViewController.h"
#import "PrimeTimeViewController.h"
#import "SpinnerViewController.h"
#import "UserProductsCollectionViewDataSource.h"
#import "ExploreDynamicInteractor.h"
#import "Li5Constants.h"
#import "ImageCardViewController.h"

@interface Li5RootFlowController ()

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) Li5ApiHandler *service;
@property (nonatomic, strong) PrimeTimeViewControllerDataSource *primeTimeDataSource;

@end

@implementation Li5RootFlowController

#pragma mark - Init

- (instancetype)initWithNavigationController:(UINavigationController *)navController
{
    DDLogVerbose(@"initializing app flow");
    self = [super init];
    if (self)
    {
        _navigationController = navController;
        _service = [Li5ApiHandler sharedInstance];

        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(showInitialScreen)
                                   name:kLoginSuccessful
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(showOnboardingScreen)
                                   name:kLoginFailed
                                 object:nil];

        [notificationCenter addObserver:self
                               selector:@selector(showOnboardingScreen)
                                   name:kLogoutSuccessful
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(showPrimeTimeScreen)
                                   name:kCategoriesUpdateSuccessful
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(logoutAndShowOnboardingScreen)
                                   name:kLoggedOutFromServer
                                 object:nil];
    }
    return self;
}

#pragma mark - App Actions

- (void)showInitialScreen
{
    DDLogVerbose(@"");
    // Do any additional setup after loading the view.
    if (!FBSDKAccessToken.currentAccessToken)
    {
        [self showOnboardingScreen];
    }
    else
    {
        [self updateUserProfile];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (![userDefaults boolForKey:kLi5CategoriesSelectionViewPresented])
        {
            [self showCategoriesSelectionScreen];
        }
        else
        {
            [self showPrimeTimeScreen];
        }
    }
}

- (void)updateUserProfile
{
    DDLogVerbose(@"");
    //Update User Profile
    __weak typeof (self) welf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __strong typeof(self) swelf = welf;
        [swelf.service requestProfile:^(NSError *profileError, Profile *profile) {
            //If anything, take the user back to login as default
            if (profileError != nil)
            {
                DDLogError(@"Error while requesting Profile %@", profileError.description);
                [swelf logoutAndShowOnboardingScreen];
            }
            else
            {
                DDLogInfo(@"Profile requested successfully");
                swelf.userProfile = profile;
                
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:kProfileUpdated object:nil];
                
                if(!profile.preferences || profile.preferences.count < 3)
                {
                    [swelf showCategoriesSelectionScreen];
                }
            }
        }];
    });
}

- (void)logoutAndShowOnboardingScreen
{
    DDLogVerbose(@"");
    if ([FBSDKAccessToken currentAccessToken] != nil)
    {
        //Logging out user - force them to log in again
        [FBSDKAccessToken setCurrentAccessToken:nil];
        
        [self showOnboardingScreen];
    }
}

- (void)__dismissPresentedViewController:(BOOL)animated
{
    if ([self.navigationController.topViewController presentedViewController])
    {
        DDLogVerbose(@"dismissing presented view controller");
        [self.navigationController.topViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)showOnboardingScreen
{
    DDLogVerbose(@"");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OnboardingViews" bundle:[NSBundle mainBundle]];
    OnboardingViewController *onboardingScreen = [storyboard instantiateInitialViewController];
    [self __dismissPresentedViewController:NO];
    [self.navigationController setViewControllers:@[onboardingScreen]];
}

- (void)showCategoriesSelectionScreen
{
    DDLogVerbose(@"");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OnboardingViews" bundle:[NSBundle mainBundle]];
    CategoriesViewController *categoriesSelectionScreen = [storyboard instantiateViewControllerWithIdentifier:@"OnboardingCategoriesView"];
    [categoriesSelectionScreen setUserProfile:self.userProfile];
    [self.navigationController setViewControllers:@[categoriesSelectionScreen]];
}

- (void)showPrimeTimeScreen
{
    DDLogVerbose(@"");
    if (!_primeTimeDataSource || [_primeTimeDataSource isExpired])
    {
        _primeTimeDataSource = [PrimeTimeViewControllerDataSource new];
    }
    PrimeTimeViewController *primeTimeVC = [[PrimeTimeViewController alloc] initWithDataSource:_primeTimeDataSource];
    
    [self __dismissPresentedViewController:NO];
    [self.navigationController setViewControllers:@[primeTimeVC]];
}

- (void)showExploreScreen
{
}

- (void)showProfileScreen
{
    
}

- (void)showSettingsScreen
{
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

@end
