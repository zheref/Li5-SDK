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

@end

@interface UserProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImg;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (nonatomic, readonly) id<UserProfileViewControllerPanTargetDelegate> panTarget;

- (id)initWithPanTarget:(id<UserProfileViewControllerPanTargetDelegate>)panTarget;

@end
