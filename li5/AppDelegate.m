//
//  AppDelegate.m
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import Li5Api;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import Fabric;
@import Crashlytics;
@import BCVideoPlayer;
@import AVFoundation;
@import Stripe;
@import Branch;
@import Intercom;
@import Instabug;
@import DigitsKit;
@import OneSignal;

#import <Applanga/Applanga.h>
#import "AppDelegate.h"
#import "CategoriesViewController.h"
#import "PrimeTimeViewController.h"
#import "Li5LoggerFormatter.h"
#import "Li5BCLoggerDelegate.h"
#import "Heap.h"
#import "Li5Constants.h"
#import "UIViewController+Indexed.h"
#import <FBNotifications/FBNotifications.h>
#import "Li5UINavigationController.h"

@interface AppDelegate () {
    BOOL __comesFromULink;
}

@end

@implementation AppDelegate

@synthesize logger;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    DDLogDebug(@"");
    NSDictionary<NSString *, id> *infoDictionary = [NSBundle mainBundle].infoDictionary;
    
    [Fabric with:@[[Crashlytics class], [Branch class], [Digits class]]];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[CrashlyticsLogger sharedInstance]];
    
    logger = [DDFileLogger new];
    logger.rollingFrequency = 60*60*24;
    [logger.logFileManager setMaximumNumberOfLogFiles:7];
    logger.doNotReuseLogFiles = YES;
    [DDLog addLogger:logger];
    
    DDLogVerbose(@"log file name: %@", logger.currentLogFileInfo.fileName);
    
    //Adding custom formatter for TTY
    Li5LoggerFormatter *logFormatter = [[Li5LoggerFormatter alloc] init];
    [DDTTYLogger sharedInstance].logFormatter = logFormatter;
    [CrashlyticsLogger sharedInstance].logFormatter = logFormatter;
    logger.logFormatter = logFormatter;
    
    // And we also enable colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blackColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
        
    //Li5 Video Player
    [BCLogger addDelegate:[Li5BCLoggerDelegate new]];
    
    //Facebook SDK
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //Stripe SDK
    [STPPaymentConfiguration sharedConfiguration].publishableKey = [infoDictionary objectForKey:@"Li5StripePublicKey"];
    
    //Intercom SDK
    [Intercom setApiKey:[infoDictionary objectForKey:@"Li5IntercomApiKey"] forAppId:[infoDictionary objectForKey:@"Li5IntercomAppId"]];
    
    //Heap Analytics
    [Heap setAppId:[infoDictionary objectForKey:@"HeapAppId"]];
    
    [OneSignal IdsAvailable:^(NSString* userId, NSString* pushToken) {
        DDLogVerbose(@"UserId:%@", userId);
        [[Li5ApiHandler sharedInstance] updateUserWithDevice:userId completion:^(NSError* err){
            if (err) {
                DDLogVerbose(@"%@",err.localizedDescription);
            }
        }];
        if (pushToken != nil) {
            DDLogVerbose(@"pushToken:%@", pushToken);
        }
    }];
    
    [OneSignal initWithLaunchOptions:launchOptions appId:[infoDictionary objectForKey:@"OneSignalAppID"] handleNotificationAction:nil settings:@{kOSSettingsKeyAutoPrompt : @FALSE}];
    
#if DEBUG
//    [Heap enableVisualizer];
    [Instabug startWithToken:[infoDictionary objectForKey:@"InstaBugToken"] invocationEvent:IBGInvocationEventShake];
#endif
    
    //Environment endpoint, uses preprocessor macro by default, overwritten by environment url
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *serverUrl = (environment[@"SERVER_URL"] ? environment[@"SERVER_URL"]
                                                      : [infoDictionary objectForKey:@"Li5ApiEndpoint"]);
    DDLogVerbose(@"Using Li5 server: %@", serverUrl);

    // Li5ApiHandler
    [[Li5ApiHandler sharedInstance] setBaseURL:serverUrl];
        
    self.navController = [[Li5UINavigationController alloc] init];
    self.navController.navigationBarHidden = YES;
    
    // LoginViewController
    _flowController = [[Li5RootFlowController alloc] initWithNavigationController:self.navController];
    
    [[Branch getInstance] registerFacebookDeepLinkingClass:[FBSDKAppLinkUtility class]];
    [[Branch getInstance] initSessionWithLaunchOptions:launchOptions];

    NSDictionary *activityDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
    if (activityDictionary) {
        NSUserActivity *userActivity = [activityDictionary valueForKey:@"UIApplicationLaunchOptionsUserActivityKey"];
        if (userActivity) {
            __comesFromULink = YES;
            [Heap track:@"Open URL" withProperties:@{@"url":userActivity.webpageURL}];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[userActivity.webpageURL lastPathComponent] forKey:kLi5Product];
        }
    }
    
    [self.window setRootViewController:self.navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    DDLogVerbose(@"");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:kUserSettingsUpdated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserSettingsUpdated object:nil];
    
    UIUserNotificationSettings *currentUserNotificationsSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    BOOL disabled = (currentUserNotificationsSettings.types == UIUserNotificationTypeNone);
    
    NSString *eventName = disabled ? @"No Push Notifications":@"Allowed Push Notifications";
    
    [Heap track:eventName withProperties:@{@"types":@(currentUserNotificationsSettings.types)}];
    
    [[Li5ApiHandler sharedInstance] updateUserProfileWithEnabledNotifications:!disabled withCompletion:^(NSError *error) {
        DDLogVerbose(@"updated notifications settings");
        if (error) {
            DDLogError(@"error, %@", error.localizedDescription);
        }
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken.description componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet]invertedSet]]componentsJoinedByString:@""];
    DDLogVerbose(@"%@",token);
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserSettingsUpdated object:nil];
    [FBSDKAppEvents setPushNotificationsDeviceToken:deviceToken];
    [Intercom setDeviceToken:deviceToken];
    [Heap track:@"Device Token Registered" withProperties:@{@"token":deviceToken}];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogVerbose(@"");
    [FBSDKAppEvents logPushNotificationOpen:userInfo];
    [Heap track:@"Remote Notification Received"];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    DDLogVerbose(@"");
    [FBSDKAppEvents logPushNotificationOpen:userInfo action:identifier];
    [Heap track:@"Remote Notification Received, Action Taken"];
}

/// Present In-App Notification from remote notification (if present).
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    DDLogVerbose(@"");
    FBNotificationsManager *notificationsManager = [FBNotificationsManager sharedManager];
    [notificationsManager presentPushCardForRemoteNotificationPayload:userInfo
                                                   fromViewController:nil
                                                           completion:^(FBNCardViewController * _Nullable viewController, NSError * _Nullable error) {
                                                               if (error) {
                                                                   completionHandler(UIBackgroundFetchResultFailed);
                                                               } else {
                                                                   completionHandler(UIBackgroundFetchResultNewData);
                                                               }
                                                           }];
    [Heap track:@"Remote Notification Received w/Handler"];
}

#pragma mark - URL Deep/Smart linking

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    DDLogVerbose(@"");
    __comesFromULink = YES;
    // For Branch to detect when a URI scheme is clicked
    if (![[Branch getInstance] handleDeepLink:url]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[url lastPathComponent] forKey:kLi5Product];
    }
    [Heap track:@"Open URL" withProperties:@{@"url":url}];
    // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

// Respond to Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    DDLogVerbose(@"");
    __comesFromULink = YES;
    [Heap track:@"Open URL" withProperties:@{@"url":userActivity.webpageURL}];
    // For Branch to detect when a Universal Link is clicked
    if(![[Branch getInstance] continueUserActivity:userActivity]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[userActivity.webpageURL lastPathComponent] forKey:kLi5Product];
    };
    return YES;
}

#pragma mark - Application States

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DDLogDebug(@"");
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([self.navController.topViewController isViewLoaded])
    {
        UIViewController *topController = [self.navController.topViewController topMostViewController];
        if (!topController.shouldAutomaticallyForwardAppearanceMethods) {
            [topController beginAppearanceTransition:NO animated:NO];
            [topController endAppearanceTransition];
        }
    }
    
    [[AVAudioSession sharedInstance] setActive:FALSE error:nil];
    __comesFromULink = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DDLogDebug(@"");
    
    //Clear Notifications Badges
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [FBSDKAppEvents activateApp];
    
    if (![_flowController hasPrimeTime] || [_flowController isPrimeTimeExpired] || __comesFromULink) {
        [_flowController showInitialScreen];
    }
    
    UIViewController *topController = [self.navController.topViewController topMostViewController];
    if ([self.navController.topViewController isViewLoaded])
    {
        if (!topController.shouldAutomaticallyForwardAppearanceMethods) {
            [topController beginAppearanceTransition:YES animated:NO];
            [topController endAppearanceTransition];
        }
    }
    
    [[AVAudioSession sharedInstance] setActive:TRUE error:nil];
    __comesFromULink = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DDLogDebug(@"");
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[[BCFileHelper alloc] init] removeCacheFromDays:1];
    
    __comesFromULink = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DDLogDebug(@"");
    
    [Applanga updateWithCompletionHandler:^(BOOL success) {
        //called if update is complete
        [self.navController.view setNeedsDisplay];
    }];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DDLogDebug(@"");
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[[BCFileHelper alloc] init] removeCacheFromDays:1];
}

@end
