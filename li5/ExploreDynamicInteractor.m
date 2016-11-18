//
//  ProductsListDynamicInteractor.m
//  li5
//
//  Created by Martin Cocaro on 5/9/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
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
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;

//@property (nonatomic, assign) BOOL shouldFinish;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) UIImageView *imagePreview;

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, readonly, weak) UIViewController *dimissingController;

@property (nonatomic, strong) ExploreViewController *productsVC;

@end

@implementation ExploreDynamicInteractor

-(id)initWithParentViewController:(UIViewController *)viewController {
    
    if (!(self = [super init])) return nil;
    
    
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.modalPresentationCapturesStatusBarAppearance = YES;
    viewController.transitioningDelegate = self;
    
    
    UIStoryboard *searchStoryboard = [UIStoryboard storyboardWithName:@"ExploreViews" bundle:[NSBundle mainBundle]];
    self.productsVC = [searchStoryboard instantiateInitialViewController];
    [self.productsVC setPanTarget:self];
    
    
    self.productsVC.modalPresentationStyle = UIModalPresentationCustom;
//    self.productsVC.modalPresentationCapturesStatusBarAppearance = YES;
    self.productsVC.transitioningDelegate = self;
    _dimissingController = viewController;
    
    return self;
}

-(void)userDidPan:(UIPanGestureRecognizer *)recognizer {
    
    self.interactive = YES;
    self.presenting = NO;
    
    CGFloat percentThreshold = 0.30;
    
    CGPoint translation = [recognizer translationInView:_dimissingController.view];
    CGFloat verticalMovement = translation.y / _dimissingController.view.bounds.size.height;
    CGFloat downwardMovement = fmaxf(verticalMovement, 0.0);
    CGFloat progress = fminf(downwardMovement, 1.0);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"%@", _dimissingController.transitioningDelegate);
        NSLog(@"%@", self.productsVC.transitioningDelegate);
        
        [_dimissingController.navigationController
         presentViewController:self.productsVC animated:YES completion:nil];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self updateInteractiveTransition: progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled) {
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
    
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    
    int blurRadius = (int)ceilf((percentComplete * 40.0));
    float saturation = (percentComplete * 1.0) + 1.0;
    UIColor *currentTint = [UIColor colorWithWhite:0.11 alpha:(percentComplete * 0.4)];
    
    UIImage *resultImage = [UIImageEffects imageByApplyingBlurToImage:_originalImage withRadius:blurRadius tintColor:currentTint saturationDeltaFactor:saturation maskImage:nil];

    _imagePreview.image = resultImage;
}

- (void)finishInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
    [UIView animateWithDuration:0.3 animations:^{
        
        _imagePreview.alpha = 0;
        toViewController.view.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [_imagePreview removeFromSuperview];
        _imagePreview.hidden = true;
        _imagePreview = nil;
        
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
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [UIView animateWithDuration:0.5f animations:^{
        
        _imagePreview.alpha = 0;
        toViewController.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        [_imagePreview removeFromSuperview];
        _imagePreview.hidden = true;
        _imagePreview = nil;
        
        [transitionContext completeTransition:NO];
    }];
}

- (void)dismissViewWithCompletion:(void (^)(void))completion
{
    CATransition *outTransition = [CATransition animation];
    outTransition.duration = 0.1;
    outTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    outTransition.type = kCATransitionFade;
    [self.productsVC.view.layer addAnimation:outTransition forKey:kCATransition];
    
    [self.productsVC dismissViewControllerAnimated:NO completion:^{
        [self.dimissingController beginAppearanceTransition:YES animated:YES];
        [self.dimissingController endAppearanceTransition];
    }];//.navigationController popViewControllerAnimated:NO];
}

@end
