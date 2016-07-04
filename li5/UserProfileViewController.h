//
//  UserProfileViewController.h
//  li5
//
//  Created by Martin Cocaro on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

// This protocol is only to silence the compiler since we're using one of two different classes.
@protocol UserProfileViewControllerPanTargetDelegate <NSObject>

- (void)userDidPan:(UIPanGestureRecognizer *)gestureRecognizer;

- (void)presentViewWithCompletion:(void (^)(void))completion;
- (void)dismissViewWithCompletion:(void (^)(void))completion;

@end

@interface UserProfileViewController : UIViewController


@property (nonatomic, weak) id<UserProfileViewControllerPanTargetDelegate> panTarget;

+ (id)initWithPanTarget:(id<UserProfileViewControllerPanTargetDelegate>)panTarget;

@end
