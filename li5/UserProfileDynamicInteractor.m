//
//  UserProfileDynamicInteractor.m
//  li5
//
//  Created by Martin Cocaro on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "UserProfileDynamicInteractor.h"
#import "UserProfileViewController.h"

@interface UserProfileDynamicInteractor () <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning, UIDynamicAnimatorDelegate>

@property (nonatomic, readonly, strong) UINavigationController *presentingViewController;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation UserProfileDynamicInteractor

- (void)presentViewWithCompletion:(void (^)(void))completion
{
    DDLogVerbose(@"beginning menu presentation");
    self.presenting = YES;
    self.interactive = NO;
    
    [self.parentViewController presentViewController:_presentingViewController animated:YES completion:^{
        self.presenting = NO;
        [self.parentViewController beginAppearanceTransition:NO animated:YES];
        [self.parentViewController endAppearanceTransition];
        if (completion) completion();
    }];
}


- (void)dismissController:(UIViewController *) controller withCompletion:(void (^)(void))completion;
{
    DDLogVerbose(@"dismissing menu presentation");
    self.interactive = NO;
    
    [controller dismissViewControllerAnimated:NO completion:^{
        [self.parentViewController beginAppearanceTransition:YES animated:YES];
        [self.parentViewController endAppearanceTransition];
        if (completion) completion();
    }];
}

- (void)dismissViewWithCompletion:(void (^)(void))completion
{
    DDLogVerbose(@"dismissing menu presentation");
    self.interactive = NO;
    
    [self.parentViewController dismissViewControllerAnimated:NO completion:^{
        [self.parentViewController beginAppearanceTransition:YES animated:YES];
        [self.parentViewController endAppearanceTransition];
        if (completion) completion();
    }];
}

-(id)initWithParentViewController:(UIViewController *)viewController {
    if (!(self = [super init])) return nil;
    
    _parentViewController = viewController;
    
    _presentingViewController = [[UINavigationController alloc] initWithRootViewController:[UserProfileViewController initWithPanTarget:self andViewController:viewController]];
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
            [self.parentViewController presentViewController:_presentingViewController animated:YES completion:nil];
        } else {
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
    
    self.presenting = NO;
    self.transitionContext = nil;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Used only in non-interactive transitions, despite the documentation
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    [self startInteractiveTransition:transitionContext];
    [self updateInteractiveTransition:1.0];
    [self finishInteractiveTransition];
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [[transitionContext containerView] bounds];
    
    [transitionContext.containerView addSubview:toViewController.view];
    
    endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
    
    toViewController.view.frame = endFrame;
    
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect presentingFrame = CGRectMake(screenBounds.origin.x, (self.presenting ? -1.0 : 1.0) * screenBounds.size.height + percentComplete , screenBounds.size.width, screenBounds.size.height);
    
    CGRect dismissingFrame = CGRectMake(screenBounds.origin.x, percentComplete, screenBounds.size.width, screenBounds.size.height);
    
    toViewController.view.frame = presentingFrame;
    fromViewController.view.frame = dismissingFrame;
}

- (void)finishInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect presentingFrame = CGRectMake(screenBounds.origin.x, (self.presenting ? 1.0 : -1.0) * screenBounds.size.height , screenBounds.size.width, screenBounds.size.height);
    
    [UIView animateWithDuration:0.5f animations:^{
        
        toViewController.view.frame = screenBounds;
        fromViewController.view.frame = presentingFrame;
        
    } completion:^(BOOL finished) {
        if (!self.presenting) {
            [[UIApplication sharedApplication].keyWindow addSubview:toViewController.view];
        }
        [transitionContext completeTransition:YES];
        [toViewController beginAppearanceTransition:YES animated:YES];
        [fromViewController beginAppearanceTransition:NO animated:YES];
        [toViewController endAppearanceTransition];
        [fromViewController endAppearanceTransition];
    }];
}

- (void)cancelInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    CGRect presentingFrame = CGRectMake(screenBounds.origin.x, (self.presenting ? -1.0 : 1.0) * screenBounds.size.height , screenBounds.size.width, screenBounds.size.height);
    
//    [fromViewController setNeedsStatusBarAppearanceUpdate];
    
    [UIView animateWithDuration:0.5f animations:^{
        toViewController.view.frame = presentingFrame;
        fromViewController.view.frame = screenBounds;
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:NO];
        
        [toViewController beginAppearanceTransition:NO animated:YES];
        [fromViewController beginAppearanceTransition:YES animated:YES];
        [toViewController endAppearanceTransition];
        [fromViewController endAppearanceTransition];
        [fromViewController setNeedsStatusBarAppearanceUpdate];
    }];
}
@end
