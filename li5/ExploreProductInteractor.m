//
//  ExploreProductInteractor.m
//  li5
//
//  Created by gustavo hansen on 11/4/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import AVFoundation;
@import CoreMedia;

#import "ExploreProductInteractor.h"
#import "PrimeTimeViewController.h"
#import "ProductPageViewController.h"

@interface ExploreProductInteractor () <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning, UIDynamicAnimatorDelegate>

@property (nonatomic, readonly, weak) UIViewController *parentViewController;
@property (nonatomic, readonly, strong) UIViewController *presentingViewController;
@property (nonatomic, assign) BOOL presented;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign, getter = isInProgress) BOOL inProgress;

@property (nonatomic, assign) BOOL shouldFinish;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property CGRect cellFrame;
@property (nonatomic, strong) UIImageView *imagePreview ;
@property (nonatomic, strong) UICollectionViewCell *cell ;
@end

@implementation ExploreProductInteractor

-(id)initWithParentViewController:(UIViewController *)viewController andChildController: (UIViewController *) child andInitialFrame: (CGRect)frame andCell:(UICollectionViewCell *)cell{
    if (!(self = [super init])) return nil;
    
    self.cellFrame = frame;
    _cell = cell;
    _parentViewController = viewController;
    _presentingViewController = child;
    _presentingViewController.modalPresentationStyle = UIModalPresentationCustom;
    _presentingViewController.modalPresentationCapturesStatusBarAppearance = YES;
    _presentingViewController.transitioningDelegate = self;
    
    _presentingViewController.view.frame = [UIScreen mainScreen].bounds;
    
    self.presented = NO;
    self.presenting = NO;
    self.interactive = NO;
    self.inProgress = NO;
    
    return self;
}

- (void) initFrame: (UIViewController *)controller {
    
    CGRect frame =  [UIScreen mainScreen].bounds;
    
    CGAffineTransform scale = CGAffineTransformMakeScale( self.cellFrame.size.width / frame.size.width ,
                                                         self.cellFrame.size.height / frame.size.height);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(self.cellFrame.origin.x, self.cellFrame.origin.y);
    controller.view.transform =  CGAffineTransformConcat(scale, translation);
}

- (void)presentViewWithCompletion:(void (^)(void))completion
{
    DDLogVerbose(@"");
    
    self.presenting = YES;
    self.interactive = NO;
    self.inProgress = YES;
    
    [self.parentViewController presentViewController:_presentingViewController animated:NO completion:^{
        self.presenting = NO;
        self.inProgress = NO;
        self.presented = YES;
        if (completion) completion();
    }];
}

-(void)userDidPan:(UIPanGestureRecognizer *)recognizer {
    DDLogVerbose(@"");
    self.interactive = YES;
    self.presenting = NO;
    
    CGFloat percentThreshold = 0.20;
    
    CGPoint translation = [recognizer translationInView:_presentingViewController.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        DDLogVerbose(@"began");
        if (!self.presenting) {
            if (self.presented) {
                self.inProgress = YES;
                [_presentingViewController dismissViewControllerAnimated:YES completion:^ {
                    self.inProgress = NO;
                }];
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        DDLogVerbose(@"changed");
        [self updateInteractiveTransition: translation.y];
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled) {
        DDLogVerbose(@"cancelled");
        [self cancelInteractiveTransition];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        DDLogVerbose(@"ended");
        CGFloat verticalMovement = translation.y / _parentViewController.view.bounds.size.height;
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
    DDLogVerbose(@"");
    self.presenting = NO;
    self.transitionContext = nil;
    self.interactive = NO;
    self.inProgress = NO;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Used only in non-interactive transitions, despite the documentation
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    DDLogVerbose(@"");
    if (!self.interactive) {
        if (self.presented) {
            DDLogVerbose(@"dismissing");
            [self animateNoInteractiveTransition:transitionContext];
        }
    }
}

- (void)animateNoInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    DDLogVerbose(@"");
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = 0;
    
    if (_presenting) {
        DDLogVerbose(@"presenting");
        [containerView addSubview:toViewController.view];
        
        CGRect frame =  [UIScreen mainScreen].bounds;
        
        toViewController.view.frame = self.cellFrame;
        
        [UIView animateWithDuration:duration animations:^{
            
            CGAffineTransform scale = CGAffineTransformMakeScale(1.0, 1.0);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(0, 0);
            toViewController.view.transform =   CGAffineTransformConcat(scale, translation);
            
        } completion:^(BOOL finished) {
            
            toViewController.view.frame = frame;
            self.presenting = NO;
            self.presented = YES;
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    DDLogVerbose(@"");
    if (self.inProgress) {
        DDLogVerbose(@"in progress");
        self.transitionContext = transitionContext;
        
        PrimeTimeNavigationViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        BCPlayer * player = [(ProductPageViewController *)((PrimeTimeViewController*)fromViewController.topViewController).currentViewController getPlayer];
        
        AVURLAsset *asset = (AVURLAsset *)player.currentItem.asset;
        AVPlayerItemVideoOutput *output = [player getOutput];
        
        CMTime time = [player currentTime] ;
        CVPixelBufferRef buffer = nil;
        
        if(output != nil && [output hasNewPixelBufferForItemTime:time]) {
            
            buffer = [output copyPixelBufferForItemTime:time itemTimeForDisplay:nil];
        }
        else if(output != nil && [output hasNewPixelBufferForItemTime:[asset duration]]) {
            
            buffer = [output copyPixelBufferForItemTime:[asset duration] itemTimeForDisplay:nil];
        }
        
        if(buffer == nil) {
            
            CGSize size = [UIScreen mainScreen].bounds.size;
            
            UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
            [fromViewController.view drawViewHierarchyInRect:CGRectMake(0, 0, size.width, size.height)
                                          afterScreenUpdates:YES];
            
            _imagePreview = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
            
            UIGraphicsEndImageContext();
            
            
        }else {
            
            CIContext *temporaryContext = [CIContext contextWithOptions:nil];
            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:buffer];
            CGImageRef videoImage = [temporaryContext
                                     createCGImage:ciImage
                                     fromRect:CGRectMake(0, 0,
                                                         CVPixelBufferGetWidth(buffer),
                                                         CVPixelBufferGetHeight(buffer))];
            
            UIImage *image = [UIImage imageWithCGImage:videoImage];
            
            CGImageRelease(videoImage);
            CVPixelBufferRelease(buffer);
            
            _imagePreview = [[UIImageView alloc] initWithImage:image];
        }
        
        [transitionContext.containerView addSubview:_imagePreview];
        fromViewController.view.hidden = true;
    } else {
        DDLogVerbose(@"not in progress");
        [transitionContext cancelInteractiveTransition];
        [transitionContext completeTransition:NO];
    }
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    DDLogVerbose(@"");
    if (self.inProgress) {
        DDLogVerbose(@"in progress");
        if(percentComplete < 0) return;
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        
        CGFloat downwardMovement = fmaxf(percentComplete / screenBounds.size.height, 0.0);
        CGFloat downwardMovementPercent = fminf(downwardMovement, 1.0);
        CGFloat progress = downwardMovementPercent;
        
        CGFloat w = screenBounds.size.width - ( screenBounds.size.width * progress);
        
        CGRect newFrame = CGRectMake((screenBounds.size.width - w) / 2, percentComplete,w,screenBounds.size.height - (screenBounds.size.height * progress));
        
        _imagePreview.frame = newFrame;
    }
}

- (void)finishInteractiveTransition {
    DDLogVerbose(@"");
    if (self.inProgress) {
        DDLogVerbose(@"in progress");
        id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
        
        self.inProgress = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            _imagePreview.frame = _cellFrame;
            
        } completion:^(BOOL finished) {
            
            [_imagePreview removeFromSuperview];
            _imagePreview.hidden = true;
            _imagePreview = nil;
            self.cell.hidden = false;
            
            _parentViewController = nil;
            _presentingViewController = nil;
            
            [transitionContext finishInteractiveTransition];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

- (void)cancelInteractiveTransition {
    DDLogVerbose(@"");
    if (self.inProgress) {
        DDLogVerbose(@"in progress");
        id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
        
        self.inProgress = NO;
        
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        [UIView animateWithDuration:0.5f animations:^{
            
            _imagePreview.frame = [UIScreen mainScreen].bounds;
            
        } completion:^(BOOL finished) {
            [_imagePreview removeFromSuperview];
            _imagePreview.hidden = true;
            _imagePreview = nil;
            fromViewController.view.hidden = false;
            
            [transitionContext cancelInteractiveTransition];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}
@end
