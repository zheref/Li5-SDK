//
//  AppDelegate.h
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Logger.h"

#import "LoginViewController.h"
#import "ProductPageViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, retain) UINavigationController *navController;

@end

