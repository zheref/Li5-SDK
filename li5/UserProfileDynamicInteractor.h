//
//  UserProfileDynamicInteractor.h
//  li5
//
//  Created by Martin Cocaro on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "UserProfileViewController.h"
#import "ProductPageProtocol.h"

@interface UserProfileDynamicInteractor : UIPercentDrivenInteractiveTransition <UserProfileViewControllerPanTargetDelegate>

- (id)initWithParentViewController:(UIViewController<DisplayableProtocol> *)viewController;

@property (nonatomic, readonly, weak) UIViewController<DisplayableProtocol> *parentViewController;

@end
