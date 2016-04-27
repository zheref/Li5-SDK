//
//  AppDelegate.m
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Li5ApiHandler.h"
#import "CategoriesViewController.h"
#import "PrimeTimeViewController.h"
#import "RootViewController.h"
#import "Li5LoggerFormatter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    //Adding custom formatter for TTY
    [DDTTYLogger sharedInstance].logFormatter = [[Li5LoggerFormatter alloc] init];
    
    // And we also enable colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blackColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
    
    //Facebook SDK
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //Environment endpoint, uses preprocessor macro by default, overwritten by environment url
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *serverUrl = (environment[@"SERVER_URL"] ? environment[@"SERVER_URL"]
                                                      : [[NSBundle mainBundle].infoDictionary objectForKey:@"Li5ApiEndpoint"]);
    DDLogVerbose(@"Using Li5 server: %@", serverUrl);

    // Li5ApiHandler
    [[Li5ApiHandler sharedInstance] setBaseURL:serverUrl];
    
    // LoginViewController
    UIViewController *initialController = ( FBSDKAccessToken.currentAccessToken != nil ?
                                           [[RootViewController alloc] init] : [[LoginViewController alloc] init] );
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:initialController];
    self.navController.navigationBarHidden = YES;
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
    //DDLogDebug(@"App resigining Active State");
    UIViewController *currentViewController = [self.navController.viewControllers lastObject];
    if ( [currentViewController isKindOfClass:[PrimeTimeViewController class]] )
    {
        [((ProductPageViewController*)[((PrimeTimeViewController*)currentViewController).viewControllers firstObject]) hideAndMoveToViewController:nil];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //DDLogDebug(@"App Did Become Active");
    
    [FBSDKAppEvents activateApp];
    
    UIViewController *currentViewController = [self.navController.viewControllers lastObject];
    if ( [currentViewController isKindOfClass:[PrimeTimeViewController class]] )
    {
        [((ProductPageViewController*)[((PrimeTimeViewController*)currentViewController).viewControllers firstObject]) show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
