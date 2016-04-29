//
//  UserProfileDynamicInteractor.h
//  li5
//
//  Created by Martin Cocaro on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "UserProfileViewController.h"

@interface UserProfileDynamicInteractor : UIPercentDrivenInteractiveTransition <UserProfileViewControllerPanTargetDelegate>

- (id)initWithParentViewController:(UIViewController *)viewController;

@property (nonatomic, readonly) UIViewController *parentViewController;

@end
