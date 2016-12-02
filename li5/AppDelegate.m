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

#import "AppDelegate.h"
#import "CategoriesViewController.h"
#import "PrimeTimeViewController.h"
#import "Li5LoggerFormatter.h"
#import "Li5BCLoggerDelegate.h"
#import "Heap.h"
#import "Li5Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize logger;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    DDLogDebug(@"");
    NSDictionary<NSString *, id> *infoDictionary = [NSBundle mainBundle].infoDictionary;
    
    [Fabric with:@[[Crashlytics class], [Branch class]]];

    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[CrashlyticsLogger sharedInstance]];
    
    logger = [DDFileLogger new];
    logger.rollingFrequency = 60*60*24;
    [logger.logFileManager setMaximumNumberOfLogFiles:7];
    logger.doNotReuseLogFiles = YES;
    [DDLog addLogger:logger];
    
    //Adding custom formatter for TTY
    Li5LoggerFormatter *logFormatter = [[Li5LoggerFormatter alloc] init];
    [DDTTYLogger sharedInstance].logFormatter = logFormatter;
    [CrashlyticsLogger sharedInstance].logFormatter = logFormatter;
    
    // And we also enable colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blackColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
    
    [BCLogger addDelegate:[Li5BCLoggerDelegate new]];
    
    //Facebook SDK
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //Stripe SDK
    [STPPaymentConfiguration sharedConfiguration].publishableKey = [infoDictionary objectForKey:@"Li5StripePublicKey"];
    
    //Intercom SDK
    [Intercom setApiKey:[infoDictionary objectForKey:@"Li5IntercomApiKey"] forAppId:[infoDictionary objectForKey:@"Li5IntercomAppId"]];
    
    //Heap Analytics
    [Heap setAppId:[infoDictionary objectForKey:@"HeapAppId"]];
#ifdef DEBUG
    [Heap enableVisualizer];
#endif
    
    [Instabug startWithToken:[infoDictionary objectForKey:@"InstaBugToken"] invocationEvent:IBGInvocationEventShake];
    
    //Environment endpoint, uses preprocessor macro by default, overwritten by environment url
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *serverUrl = (environment[@"SERVER_URL"] ? environment[@"SERVER_URL"]
                                                      : [infoDictionary objectForKey:@"Li5ApiEndpoint"]);
    DDLogVerbose(@"Using Li5 server: %@", serverUrl);

    // Li5ApiHandler
    [[Li5ApiHandler sharedInstance] setBaseURL:serverUrl];
    
    self.navController = [[UINavigationController alloc] init];
    self.navController.navigationBarHidden = YES;
    
    // LoginViewController
    _flowController = [[Li5RootFlowController alloc] initWithNavigationController:self.navController];
//    [_flowController showInitialScreen];
    
    [[Branch getInstance] initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error && [[params objectForKey:@"+clicked_branch_link"] boolValue]) {
            DDLogVerbose(@"share link token: %@", [params objectForKey:@"share_token"]);
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[params objectForKey:@"share_token"] forKey:kLi5ShareToken];
            [_flowController showInitialScreen];
        }
    }];
    
    [self.window setRootViewController:self.navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // For Branch to detect when a URI scheme is clicked
    [[Branch getInstance] handleDeepLink:url];
    // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

// Respond to Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    // For Branch to detect when a Universal Link is clicked
    [[Branch getInstance] continueUserActivity:userActivity];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DDLogDebug(@"");
    
    [[AVAudioSession sharedInstance] setActive:FALSE error:nil];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([self.navController.topViewController isViewLoaded])
    {
        [self.window.rootViewController beginAppearanceTransition:NO animated:NO];
        [self.window.rootViewController endAppearanceTransition];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DDLogDebug(@"");
    
    [FBSDKAppEvents activateApp];
    
    [[AVAudioSession sharedInstance] setActive:TRUE error:nil];
    
    if ([self.navController.topViewController isViewLoaded])
    {
        if (![self.navController.topViewController presentedViewController]) {
            [self.window.rootViewController beginAppearanceTransition:YES animated:NO];
            [self.window.rootViewController endAppearanceTransition];
        }
    } else {
        //TODO This causes the spinner to blink since iOS will move the app to foreground prior to handling the URL.
        //TODO we need to move the logic of expiration of PrimeTime to DidBecomeActive method
        [_flowController showInitialScreen];
    }
    
    [[[BCFileHelper alloc] init] removeCacheFromDays:1];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DDLogDebug(@"");
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.window.rootViewController beginAppearanceTransition:NO animated:NO];
    [self.window.rootViewController endAppearanceTransition];
    
    [[[BCFileHelper alloc] init] removeCacheFromDays:1];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DDLogDebug(@"");
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DDLogDebug(@"");
}

@end
