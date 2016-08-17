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

@property (nonatomic, assign, getter=isInteractive) BOOL interactive;
@property (nonatomic, assign, getter=isPresenting) BOOL presenting;
@property (nonatomic, assign, getter=isCompleting) BOOL completing;
@property (nonatomic, assign, getter=isInteractiveTransitionInteracting) BOOL interactiveTransitionInteracting;
@property (nonatomic, assign, getter=isInteractiveTransitionUnderway) BOOL interactiveTransitionUnderway;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehaviour;
@property (nonatomic, assign) CGPoint lastKnownVelocity;

@property (nonatomic, assign) BOOL presented;

@property (nonatomic, readonly, strong) UINavigationController *presentingViewController;

@end

@implementation UserProfileDynamicInteractor

#pragma mark - Public Methods

- (id)initWithParentViewController:(UIViewController<DisplayableProtocol> *)parentVC
{
    if (!(self = [super init]))
        return nil;
    
    _parentViewController = parentVC;

    _presentingViewController = [[UINavigationController alloc] initWithRootViewController:[UserProfileViewController initWithPanTarget:self]];
    _presentingViewController.modalPresentationStyle = UIModalPresentationCustom;
    _presentingViewController.transitioningDelegate = self;
    
    _presented = FALSE;
    
    return self;
}

/*
 Note: Unlike when we connect a gesture recognizer to a view via an attachment behaviour,
 our recognizer is going to remain agnostic to how the view controller is presented.
 */
- (void)userDidPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.parentViewController.view];
    CGPoint velocity = [recognizer velocityInView:self.parentViewController.view];

    self.lastKnownVelocity = velocity;

    // Note: Only one presentation may occur at a time, as per usual

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // We *must* check if we already have an interactive transition underway
        // TODO: Still need this?
        if (self.interactiveTransitionUnderway == NO)
        {
            // We're being invoked via a gesture recognizer – we are necessarily interactive
            self.interactive = YES;

            // The side of the screen we're panning from determines whether this is a presentation (left) or dismissal (right)
            if (location.y < CGRectGetMidY(recognizer.view.bounds) && !self.presenting && !self.presented)
            {
                [self presentViewWithCompletion:nil];
            }
            else if (self.presented && !self.presenting)
            {
                [self dismissViewWithCompletion:nil];
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // Determine our ratio between the top edge and the bottom edge. This means our dismissal will go from 1...0.
        CGFloat ratio = location.y / CGRectGetHeight(self.parentViewController.view.bounds);
        [self updateInteractiveTransition:ratio];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // Depending on our state and the velocity, determine whether to cancel or complete the transition.
        if (self.interactiveTransitionInteracting)
        {
            DDLogVerbose(@"ending interactive transition");
            if (self.presenting)
            {
                if (velocity.y > 0)
                {
                    DDLogVerbose(@"finishing interactive transition");
                    [self finishInteractiveTransition];
                }
                else
                {
                    DDLogVerbose(@"canceling interactive transition");
                    [self cancelInteractiveTransition];
                }
            }
            else
            {
                if (velocity.y < 0)
                {
                    DDLogVerbose(@"finishing interactive transition");
                    [self finishInteractiveTransition];
                }
                else
                {
                    DDLogVerbose(@"canceling interactive transition");
                    [self cancelInteractiveTransition];
                }
            }
        }
    }
}

- (void)presentViewWithCompletion:(void (^)(void))completion
{
    DDLogVerbose(@"beginning menu presentation");
    self.presenting = YES;
    
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.3;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromBottom;
//    [self.parentViewController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.parentViewController presentViewController:_presentingViewController animated:NO completion:^{
        self.presented = YES;
        self.presenting = NO;
        [self.parentViewController viewDidDisappear:NO];
        if (completion) completion();
    }];
}

- (void)dismissViewWithCompletion:(void (^)(void))completion
{
    DDLogVerbose(@"dismissing menu presentation");
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.3;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromTop;
//    [_presentingViewController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.parentViewController dismissViewControllerAnimated:NO completion:^{
        self.presented = NO;
        [self.parentViewController viewDidAppear:NO];
        if (completion) completion();
    }];
}


#pragma mark - Private Methods

- (void)ensureSimulationCompletesWithDesiredEndFrame:(CGRect)endFrame
{
    // Take a "snapshot" of the transitionContext when this method is first invoked. We'll compare it to self.transitionContext
    // When the dispatch_after block is invoked.
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    // We need to *guarantee* that our transition completes at some point.
    double delayInSeconds = [self transitionDuration:self.transitionContext];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
      // If we still have an animator, we're still animating, so we need to complete our transition immediately.
      id<UIViewControllerContextTransitioning> blockContext = self.transitionContext;
      UIDynamicAnimator *blockAnimator = self.animator;

      if (blockAnimator && blockContext == transitionContext)
      {
          BOOL presenting = self.presenting;

          [transitionContext completeTransition:YES];

          if (presenting)
          {
              toViewController.view.frame = endFrame;
          }
          else
          {
              fromViewController.view.frame = endFrame;
          }
      }
    });
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    // Return nil if we are not interactive
    if (self.interactive)
    {
        return self;
    }

    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    // Return nil if we are not interactive
    if (self.interactive)
    {
        return self;
    }

    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (void)animationEnded:(BOOL)transitionCompleted
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    fromViewController.view.userInteractionEnabled = YES;
    toViewController.view.userInteractionEnabled = YES;

    // Reset to our default state
    self.interactive = NO;
    self.presenting = NO;
    self.transitionContext = nil;
    self.completing = NO;
    self.interactiveTransitionInteracting = NO;
    self.interactiveTransitionUnderway = NO;

    [self.animator removeAllBehaviors], self.animator.delegate = nil, self.animator = nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // Instead of using this to animate a transition, we'll use it as an upper-bounds to the UIKit Dynamics simulation elapsedTime.
    // We'll use 2 seconds.
    return 2.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;

    if (self.interactive)
    {
        // nop as per documentation
    }
    else
    {
        // Guaranteed to complete since this is a non-interactive transition
        self.completing = YES;

        // This code is lifted wholesale from the TLTransitionAnimator class
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

        CGRect startFrame = [[transitionContext containerView] bounds];
        CGRect endFrame = [[transitionContext containerView] bounds];

        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:transitionContext.containerView];
        self.animator.delegate = self;

        if (self.presenting)
        {
            // The order of these matters – determines the view hierarchy order.
            [transitionContext.containerView addSubview:toViewController.view];

            startFrame.origin.y -= CGRectGetHeight([[transitionContext containerView] bounds]);

            toViewController.view.frame = startFrame;

            UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[ toViewController.view ]];
            [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-CGRectGetHeight(transitionContext.containerView.bounds), 0, 0, 0)];

            UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[ toViewController.view ]];
            gravityBehaviour.gravityDirection = CGVectorMake(0.0f, 5.0f);

            UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[ toViewController.view ]];
            itemBehaviour.elasticity = 0.5f;

            [self.animator addBehavior:collisionBehaviour];
            [self.animator addBehavior:gravityBehaviour];
            //[self.animator addBehavior:itemBehaviour];
        }
        else
        {
            endFrame.origin.y -= CGRectGetHeight(self.transitionContext.containerView.bounds);

            fromViewController.view.frame = startFrame;

            UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[ fromViewController.view ]];
            [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-CGRectGetHeight(transitionContext.containerView.bounds), 0, 0, 0)];

            UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[ fromViewController.view ]];
            gravityBehaviour.gravityDirection = CGVectorMake(0.0f, -5.0f);

            UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[ fromViewController.view ]];
            itemBehaviour.elasticity = 0.5f;

            [self.animator addBehavior:collisionBehaviour];
            [self.animator addBehavior:gravityBehaviour];
            //[self.animator addBehavior:itemBehaviour];
        }

        [self ensureSimulationCompletesWithDesiredEndFrame:endFrame];
    }
}

#pragma mark - UIViewControllerInteractiveTransitioning Methods

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSAssert(self.animator == nil, @"Duplicating animators – likely two presentations running concurrently.");

    self.transitionContext = transitionContext;
    self.interactiveTransitionInteracting = YES;
    self.interactiveTransitionUnderway = YES;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    fromViewController.view.userInteractionEnabled = NO;

    CGRect frame = [[transitionContext containerView] bounds];

    if (self.presenting)
    {
        [transitionContext.containerView addSubview:toViewController.view];

        frame.origin.y -= CGRectGetHeight([[transitionContext containerView] bounds]);
    }

    toViewController.view.frame = frame;

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:transitionContext.containerView];
    self.animator.delegate = self;

    id<UIDynamicItem> dynamicItem;

    if (self.presenting)
    {
        dynamicItem = toViewController.view;
        self.attachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:dynamicItem attachedToAnchor:CGPointMake(CGRectGetMidX(transitionContext.containerView.bounds),0.0f)];
    }
    else
    {
        dynamicItem = fromViewController.view;
        self.attachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:dynamicItem attachedToAnchor:CGPointMake(CGRectGetHeight(transitionContext.containerView.bounds), CGRectGetMidX(transitionContext.containerView.bounds))];
    }

    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[ dynamicItem ]];
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-CGRectGetHeight(transitionContext.containerView.bounds), 0, 0, 0)];

    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[ dynamicItem ]];
    itemBehaviour.elasticity = 0.5f;

    [self.animator addBehavior:collisionBehaviour];
    //[self.animator addBehavior:itemBehaviour];
    [self.animator addBehavior:self.attachmentBehaviour];
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    self.attachmentBehaviour.anchorPoint = CGPointMake(CGRectGetMidX(self.transitionContext.containerView.bounds),CGRectGetHeight(self.transitionContext.containerView.bounds) * percentComplete);
}

- (void)finishInteractiveTransition
{
    self.interactiveTransitionInteracting = NO;
    self.completing = YES;
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    [self.animator removeBehavior:self.attachmentBehaviour];

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect endFrame = transitionContext.containerView.bounds;

    id<UIDynamicItem> dynamicItem;
    CGFloat gravityYComponent = 0.0f;

    if (self.presenting)
    {
        dynamicItem = toViewController.view;
        gravityYComponent = 5.0f;
    }
    else
    {
        dynamicItem = fromViewController.view;
        gravityYComponent = -5.0f;
        
        endFrame.origin.y -= CGRectGetHeight(endFrame);
    }

    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[ dynamicItem ]];
    gravityBehaviour.gravityDirection = CGVectorMake(0.0f,gravityYComponent);

    UIPushBehavior *pushBehaviour = [[UIPushBehavior alloc] initWithItems:@[ dynamicItem ] mode:UIPushBehaviorModeInstantaneous];
    pushBehaviour.pushDirection = CGVectorMake(0.0f,self.lastKnownVelocity.y / 10.0f);

    [self.animator addBehavior:gravityBehaviour];
    [self.animator addBehavior:pushBehaviour];

    [self ensureSimulationCompletesWithDesiredEndFrame:endFrame];
}

- (void)cancelInteractiveTransition
{
    self.interactiveTransitionInteracting = NO;
    self.presented = NO;
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    [self.animator removeBehavior:self.attachmentBehaviour];

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect endFrame = transitionContext.containerView.bounds;

    id<UIDynamicItem> dynamicItem;
    CGFloat gravityYComponent = 0.0f;

    if (self.presenting)
    {
        dynamicItem = toViewController.view;
        gravityYComponent = -5.0f;

        endFrame.origin.y -= CGRectGetHeight(endFrame);
    }
    else
    {
        dynamicItem = fromViewController.view;
        gravityYComponent = 5.0f;
    }

    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[ dynamicItem ]];
    gravityBehaviour.gravityDirection = CGVectorMake(0.0f,gravityYComponent);

    UIPushBehavior *pushBehaviour = [[UIPushBehavior alloc] initWithItems:@[ dynamicItem ] mode:UIPushBehaviorModeInstantaneous];
    pushBehaviour.pushDirection = CGVectorMake(0.0f,self.lastKnownVelocity.y / 10.0f);

    [self.animator addBehavior:gravityBehaviour];
    [self.animator addBehavior:pushBehaviour];

    [self ensureSimulationCompletesWithDesiredEndFrame:endFrame];
}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    // We need this check to determine if the user is still interacting with the transition (ie: they stopped moving their finger)
    if (!self.interactiveTransitionInteracting)
    {
        [self.transitionContext completeTransition:self.completing];
    }
}

@end
