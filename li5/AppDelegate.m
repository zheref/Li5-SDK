//
//  AppDelegate.m
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import Fabric;
@import Crashlytics;
@import BCVideoPlayer;
@import AVFoundation;

#import "AppDelegate.h"
#import "CategoriesViewController.h"
#import "PrimeTimeViewController.h"
#import "Li5LoggerFormatter.h"
#import "Li5BCLoggerDelegate.h"
#import "Heap.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize logger;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    DDLogDebug(@"");
    [Fabric with:@[[Crashlytics class]]];

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
    
    NSDictionary<NSString *, id> *infoDictionary = [NSBundle mainBundle].infoDictionary;
    
    //Heap Analytics
    [Heap setAppId:[infoDictionary objectForKey:@"HeapAppId"]];
#ifdef DEBUG
    [Heap enableVisualizer];
#endif
    
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
    [_flowController showInitialScreen];
    
    [self.window setRootViewController:self.navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DDLogDebug(@"");
    
    [[AVAudioSession sharedInstance] setActive:FALSE error:nil];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.window.rootViewController beginAppearanceTransition:NO animated:NO];
    [self.window.rootViewController endAppearanceTransition];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DDLogDebug(@"");
    
    [FBSDKAppEvents activateApp];
    
    [[AVAudioSession sharedInstance] setActive:TRUE error:nil];
    
    if ([self.navController.topViewController isViewLoaded])
    {
        [self.window.rootViewController beginAppearanceTransition:YES animated:NO];
        [self.window.rootViewController endAppearanceTransition];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DDLogDebug(@"");
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DDLogDebug(@"");
    
    [_flowController showInitialScreen];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DDLogDebug(@"");
}

@end
