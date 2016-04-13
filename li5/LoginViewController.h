//
//  InitialViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Logger.h"
#import "RootViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface LoginViewController : UIViewController <FBSDKLoginButtonDelegate>

@end
