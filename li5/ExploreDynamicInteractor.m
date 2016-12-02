//
//  ProductsListDynamicInteractor.m
//  li5
//
//  Created by Martin Cocaro on 5/9/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import AVFoundation;
@import CoreMedia;

#import "ExploreDynamicInteractor.h"
#import "ExploreViewController.h"
#import "UIImageEffects.h"
#import "PrimeTimeViewController.h"

@interface ExploreDynamicInteractor () <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning, UIDynamicAnimatorDelegate>

//@property (nonatomic, readonly, strong) UIViewController *parentViewController;
//@property (nonatomic, readonly, strong) UIViewController *presentingViewController;
@property (nonatomic, assign) BOOL presented;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign, getter = isInProgress) BOOL inProgress;

//@property (nonatomic, assign) BOOL shouldFinish;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) UIImageView *imagePreview;

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, readonly, weak) UIViewController *dimissingController;

@property (nonatomic, strong) ExploreViewController *exploreProductsViewController;

@end

@implementation ExploreDynamicInteractor

-(id)initWithParentViewController:(UIViewController *)trigeringViewController {
    
    if (!(self = [super init])) return nil;
    
//    trigeringViewController.modalPresentationStyle = UIModalPresentationCustom;
//    trigeringViewController.modalPresentationCapturesStatusBarAppearance = YES;
//    trigeringViewController.transitioningDelegate = self;
    
    UIStoryboard *searchStoryboard = [UIStoryboard storyboardWithName:@"ExploreViews" bundle:[NSBundle mainBundle]];
    self.exploreProductsViewController = [searchStoryboard instantiateInitialViewController];
    [self.exploreProductsViewController setPanTarget:self];
    
    self.exploreProductsViewController.modalPresentationStyle = UIModalPresentationCustom;
    self.exploreProductsViewController.modalPresentationCapturesStatusBarAppearance = YES;
    self.exploreProductsViewController.transitioningDelegate = self;
    _dimissingController = trigeringViewController;
    
    self.presented = NO;
    self.presenting = NO;
    self.interactive = NO;
    self.inProgress = NO;
    
    return self;
}

-(void)userDidPan:(UIPanGestureRecognizer *)recognizer {
    DDLogVerbose(@"");
    self.interactive = YES;
    
    CGFloat percentThreshold = 0.30;
    
    CGPoint translation = [recognizer translationInView:_dimissingController.view];
    CGFloat verticalMovement = translation.y / _dimissingController.view.bounds.size.height;
    CGFloat downwardMovement = fmaxf(verticalMovement, 0.0);
    CGFloat progress = fminf(downwardMovement, 1.0);
    
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStatePossible) {
        
        CGPoint velocity = [recognizer velocityInView:_dimissingController.view];
        self.presenting = velocity.y > 0;
        
        if (self.presenting) {
            if(!self.presented) {
                self.inProgress = YES;
                [_dimissingController.navigationController
                 presentViewController:self.exploreProductsViewController animated:YES completion:nil];
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self updateInteractiveTransition: progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        [self cancelInteractiveTransition];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
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
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Used only in non-interactive transitions, despite the documentation
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    DDLogVerbose(@"");
    if (!self.interactive) {
        [self startInteractiveTransition:transitionContext];
        [self updateInteractiveTransition:1.0];
        [self finishInteractiveTransition];
    }
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.inProgress) {
        DDLogVerbose(@"");
        self.transitionContext = transitionContext;
        
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        toViewController.view.userInteractionEnabled = false;
        toViewController.view.alpha = 0;
        UINavigationController * navController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        PrimeTimeViewController *fromViewController = [navController.viewControllers firstObject];
        
        BCPlayer * player = [(ProductPageViewController *)fromViewController.currentViewController getPlayer];
        
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
        _originalImage = _imagePreview.image;
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:_imagePreview];
    } else {
        [transitionContext cancelInteractiveTransition];
        [transitionContext completeTransition:NO];
    }
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    if (self.inProgress) {
        DDLogVerbose(@"%f",percentComplete);
        int blurRadius = (int)ceilf((percentComplete * 40.0));
        float saturation = (percentComplete * 1.0) + 1.0;
        UIColor *currentTint = [UIColor colorWithWhite:0.11 alpha:(percentComplete * 0.4)];
        
        UIImage *resultImage = [UIImageEffects imageByApplyingBlurToImage:_originalImage withRadius:blurRadius tintColor:currentTint saturationDeltaFactor:saturation maskImage:nil];
        
        _imagePreview.image = resultImage;
        
        id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
        
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        _imagePreview.alpha = 1.0 - percentComplete;
        fromViewController.view.alpha = 1.0 - percentComplete;
        toViewController.view.alpha = percentComplete;
    }
}

- (void)finishInteractiveTransition {
    if (self.inProgress) {
        DDLogVerbose(@"");
        id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
        
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        _imagePreview.alpha = 0;
        toViewController.view.alpha = 1.0;
        fromViewController.view.alpha = 1.0;
        
        self.presented = self.presenting;
        
        [_imagePreview removeFromSuperview];
        _imagePreview.hidden = true;
        _imagePreview = nil;
        
        toViewController.view.userInteractionEnabled = true;
        
        [fromViewController beginAppearanceTransition:NO animated:YES];
        [fromViewController endAppearanceTransition];
        [toViewController beginAppearanceTransition:YES animated:YES];
        [toViewController endAppearanceTransition];
        [transitionContext finishInteractiveTransition];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        self.inProgress = NO;
    }
}

- (void)cancelInteractiveTransition {
    if (self.inProgress) {
        DDLogVerbose(@"");
        id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
        
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        _imagePreview.alpha = 0;
        fromViewController.view.alpha = 1.0;
        toViewController.view.alpha = 0;
        
        [toViewController.view removeFromSuperview];
        
        [_imagePreview removeFromSuperview];
        _imagePreview.hidden = true;
        _imagePreview = nil;
        
        self.presenting = NO;
        self.presented = NO;
        
        [toViewController beginAppearanceTransition:NO animated:YES];
        [toViewController endAppearanceTransition];
        [fromViewController beginAppearanceTransition:YES animated:YES];
        [fromViewController endAppearanceTransition];
        [transitionContext cancelInteractiveTransition];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        self.inProgress = NO;
    }
}

- (void)dismissViewWithCompletion:(void (^)(void))completion {
    DDLogVerbose(@"");
    CATransition *outTransition = [CATransition animation];
    outTransition.duration = 0.1;
    outTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    outTransition.type = kCATransitionFade;
    [self.exploreProductsViewController.view.layer addAnimation:outTransition forKey:kCATransition];
    
    [self.exploreProductsViewController dismissViewControllerAnimated:NO completion:^{
        self.presenting = NO;
        self.presented = NO;
        self.interactive = NO;
        self.inProgress = NO;
        [self.dimissingController beginAppearanceTransition:YES animated:YES];
        [self.dimissingController endAppearanceTransition];
    }];//.navigationController popViewControllerAnimated:NO];
}

@end
