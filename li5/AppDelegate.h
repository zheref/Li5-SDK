//
//  AppDelegate.h
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "Li5RootFlowController.h"
#import "LoginViewController.h"
#import "ProductPageViewController.h"
#import "Li5UINavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, retain) Li5UINavigationController *navController;

@property (nonatomic, strong) DDFileLogger *logger;

@property (nonatomic, strong) Li5RootFlowController *flowController;

@end

