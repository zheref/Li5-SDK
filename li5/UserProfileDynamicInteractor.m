//
//  UserProfileDynamicInteractor.m
//  li5
//
//  Created by Martin Cocaro on 4/27/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "UserProfileDynamicInteractor.h"
#import "UserProfileViewController.h"

@interface UserProfileDynamicInteractor () <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning, UIDynamicAnimatorDelegate>

@property (nonatomic, readonly, strong) UINavigationController *presentingViewController;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, assign) BOOL presented;
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign, getter = isInProgress) BOOL inProgress;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation UserProfileDynamicInteractor

- (void)presentViewWithCompletion:(void (^)(void))completion
{
    DDLogVerbose(@"beginning menu presentation");
    self.presenting = YES;
    self.interactive = NO;
    self.inProgress = YES;
    
    [self.parentViewController presentViewController:_presentingViewController animated:YES completion:^{
        self.presenting = NO;
        self.presented =  YES;
        [self.parentViewController beginAppearanceTransition:NO animated:YES];
        [self.parentViewController endAppearanceTransition];
        if (completion) completion();
        self.inProgress = NO;
    }];
}

- (void)dismissController:(UIViewController *) controller withCompletion:(void (^)(void))completion
{
    DDLogVerbose(@"dismissing menu presentation");
    self.interactive = NO;
    self.inProgress = YES;
    
    [controller dismissViewControllerAnimated:YES completion:^{
        [self.parentViewController beginAppearanceTransition:YES animated:YES];
        [self.parentViewController endAppearanceTransition];
        if (completion) completion();
        self.inProgress = NO;
    }];
}

-(id)initWithParentViewController:(UIViewController *)viewController {
    if (!(self = [super init])) return nil;
    
    _parentViewController = viewController;
    
    _presentingViewController = [[UserProfileNavigationViewController alloc] initWithRootViewController:[UserProfileViewController initWithPanTarget:self andViewController:viewController]];
    _presentingViewController.modalPresentationStyle = UIModalPresentationCustom;
    _presentingViewController.modalPresentationCapturesStatusBarAppearance = YES;
    _presentingViewController.transitioningDelegate = self;
    
    return self;
}

-(void)userDidPan:(UIScreenEdgePanGestureRecognizer *)recognizer {
    
    self.interactive = YES;
    // Note: Only one presentation may occur at a time, as per usual
    
    CGFloat percentThreshold = 0.15;
    
    // convert y-position to downward pull progress (percentage)
    CGPoint translation = [recognizer translationInView:_parentViewController.view ];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint velocity = [recognizer velocityInView:self.parentViewController.view];
        self.presenting = velocity.y > 0;
        
        if (self.presenting) {
            if(!self.presented) {
                self.inProgress = YES;
                [self.parentViewController presentViewController:_presentingViewController animated:YES completion:nil];
            }
        } else {
            self.inProgress = YES;
            [_presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self updateInteractiveTransition:translation.y];
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled) {
        [self cancelInteractiveTransition];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGFloat verticalMovement = translation.y / _parentViewController.view.bounds.size.height * (self.presenting ? 1 : -1);
        CGFloat downwardMovement = fmaxf(verticalMovement, 0.0);
        CGFloat progress = fminf(downwardMovement, 1.0);
        
        if (progress > percentThreshold) {
            [self finishInteractiveTransition];
        }
        else {
            [self cancelInteractiveTransition];
        }
    }
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    if (_interactive)
        return self;
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    if (_interactive)
        return self;
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (void)animationEnded:(BOOL)transitionCompleted {
    DDLogDebug(@"");
    self.presenting = NO;
    self.transitionContext = nil;
    self.interactive = NO;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Used only in non-interactive transitions, despite the documentation
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    DDLogDebug(@"");
    if (!self.interactive) {
        self.inProgress = YES;
        [self startInteractiveTransition:transitionContext];
        [self updateInteractiveTransition:1.0];
        [self finishInteractiveTransition];
    }
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.inProgress) {
        DDLogDebug(@"");
        self.transitionContext = transitionContext;
        
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        CGRect endFrame = [[transitionContext containerView] bounds];
        
        toViewController.view.alpha = 0;
        toViewController.view.frame = endFrame;
        
        toViewController.view.userInteractionEnabled = true;
    } else {
        [transitionContext cancelInteractiveTransition];
        [transitionContext completeTransition:NO];
    }
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    if (self.inProgress) {
        DDLogDebug(@"");
        id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
        
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGRect presentingFrame = CGRectMake(screenBounds.origin.x, (self.presenting ? -1.0 : 1.0) * screenBounds.size.height + percentComplete , screenBounds.size.width, screenBounds.size.height);
        
        CGRect dismissingFrame = CGRectMake(screenBounds.origin.x, percentComplete, screenBounds.size.width, screenBounds.size.height);
        
        toViewController.view.alpha = 1.0;
        toViewController.view.frame = presentingFrame;
        fromViewController.view.frame = dismissingFrame;
    } else {
        [self.transitionContext cancelInteractiveTransition];
        [self.transitionContext completeTransition:NO];
    }
}

- (void)finishInteractiveTransition {
    if (self.inProgress) {
        DDLogDebug(@"");
        id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
        
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGRect presentingFrame = CGRectMake(screenBounds.origin.x, (self.presenting ? 1.0 : -1.0) * screenBounds.size.height , screenBounds.size.width, screenBounds.size.height);
        
        [UIView animateWithDuration:0.5f animations:^{
            
            toViewController.view.frame = screenBounds;
            fromViewController.view.frame = presentingFrame;
            
        } completion:^(BOOL finished) {
            
            self.presented = self.presenting;
            
            if (!self.presenting) {
                [[UIApplication sharedApplication].keyWindow addSubview:toViewController.view];
            }
            toViewController.view.userInteractionEnabled = true;
            if (self.interactive || !self.presenting) {
                if (self.presenting) {
                    [fromViewController beginAppearanceTransition:NO animated:YES];
                    [fromViewController endAppearanceTransition];
                } else {
                    [toViewController beginAppearanceTransition:YES animated:YES];
                    [toViewController endAppearanceTransition];
                }
            }
            if (self.interactive) {
                [transitionContext finishInteractiveTransition];
            }
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            self.inProgress = NO;
        }];
    }
}

- (void)cancelInteractiveTransition {
    if (self.inProgress) {
        DDLogDebug(@"");
        id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
        
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        
        CGRect presentingFrame = CGRectMake(screenBounds.origin.x, (self.presenting ? -1.0 : 1.0) * screenBounds.size.height , screenBounds.size.width, screenBounds.size.height);
        
        [UIView animateWithDuration:0.5f animations:^{
            toViewController.view.frame = presentingFrame;
            fromViewController.view.frame = screenBounds;
            
        } completion:^(BOOL finished) {
            if (self.interactive || !self.presenting) {
                if (self.presenting) {
                    [toViewController beginAppearanceTransition:NO animated:YES];
                    [toViewController endAppearanceTransition];
                } else {
                    [fromViewController beginAppearanceTransition:YES animated:YES];
                    [fromViewController endAppearanceTransition];
                }
            }
            if (self.interactive) {
                [transitionContext cancelInteractiveTransition];
            }
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            self.inProgress = NO;
        }];
    }
}
@end
