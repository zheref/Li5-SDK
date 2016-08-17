//
//  UnlockedViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "Li5PlayerUISlider.h"
#import "UnlockedViewController.h"
#import "ProductPageViewController.h"
#import "ProductPageActionsView.h"
#import "Li5VolumeView.h"
#import "Li5-Swift.h"

static const CGFloat sliderHeight = 50.0;
static const CGFloat kCAHideControls = 3.5;

@interface UnlockedViewController ()
{
    id __playEndObserver;
    NSTimer *hideControlsTimer;

    UIPanGestureRecognizer *_lockPanGestureRecognzier;
    UITapGestureRecognizer *_simpleTapGestureRecognizer;
    
    BOOL __hasAppeared;
    BOOL __renderingAnimations;
    BOOL __locked;
}

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) BCPlayer *extendedVideo;
@property (strong, nonatomic) BCPlayerLayer *playerLayer;

@property (weak, nonatomic) IBOutlet Li5PlayerUISlider *seekSlider;
@property (weak, nonatomic) IBOutlet ProductPageActionsView *actionsView;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;

@property (strong, nonatomic) Wave *waveView;

//Appearance Animation
@property (nonatomic, strong) CAShapeLayer *dot;
@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, assign) double dismissThreshold;
@property (nonatomic, assign) double presentAnimationDuration;

@end

@implementation UnlockedViewController

@synthesize product;

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _dotColor = [UIColor li5_redColor];
    _dismissThreshold = 0.05; // 0.0 < dismissThreashold <= 1.1
    _presentAnimationDuration = 0.35;
    __locked = YES;
}

+ (id)unlockedWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx;
{
    UIStoryboard *productPageStoryboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle mainBundle]];
    UnlockedViewController *newSelf = [productPageStoryboard instantiateViewControllerWithIdentifier:@"UnlockedView"];
    if (newSelf)
    {
        DDLogVerbose(@"%@", thisProduct.id);
        newSelf.product = thisProduct;
        NSURL *videoUrl = [NSURL URLWithString:newSelf.product.videoURL];
        newSelf.extendedVideo = [[BCPlayer alloc] initWithUrl:videoUrl bufferInSeconds:20.0 priority:BCPriorityUnLock delegate:newSelf];
        newSelf.playerLayer = [[BCPlayerLayer alloc] initWithPlayer:newSelf.extendedVideo andFrame:[UIScreen mainScreen].bounds];
    }
    return newSelf;
}

#pragma mark - UI View

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    
//    NSData *posterData = [[NSData alloc] initWithBase64EncodedString:self.product.poster64 options:0];
//    UIImage *posterImage = [UIImage imageWithData:posterData];
//    UIImageView *posterImageView = [[UIImageView alloc] initWithImage:posterImage];
//    posterImageView.frame = self.view.bounds;
//    [self.playerView addSubview:posterImageView];
    
    // Do any additional setup after loading the view.
    self.playerLayer.frame = self.view.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.playerView.layer addSublayer:self.playerLayer];
    
    [self.actionsView setProduct:self.product];
    
    CGRect rect = CGRectMake(self.initialPoint.x, self.initialPoint.y, 1, 1);
    
    _dot = [CAShapeLayer layer];
    _dot.anchorPoint = CGPointZero;
    _dot.contentsScale = [UIScreen mainScreen].scale;
    _dot.shouldRasterize = YES;
    _dot.backgroundColor = [UIColor clearColor].CGColor;
    _dot.path = [self mainPathForRect:rect].CGPath;
    _dot.shadowRadius = 5;
    _dot.shadowColor = self.view.backgroundColor.CGColor;
    _dot.shadowOpacity = 1;
    _dot.shadowOffset = CGSizeZero;
    _dot.shadowPath = [self shadowPathForRect:rect].CGPath;
    _dot.opacity = 0.9;
    
    self.view.layer.mask = self.dot;
    
    [self setupGestureRecognizers];
    
    [self renderAnimations];
    
    [self __renderMore];
    
    _waveView = [[Wave alloc] initWithView:self.view];
    [_waveView startAnimating];
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
    
    __hasAppeared = NO;
    
    [self.extendedVideo pause];
    
    [self removeObservers];
    
    [self updateSecondsWatched];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    __hasAppeared = YES;
    
    if (self.dot && __locked)
    {
        __locked = NO;
        self.view.userInteractionEnabled = false;
        
        CGRect rect = CGRectMake(self.initialPoint.x, self.initialPoint.y, 1, 1);
        UIBezierPath *fromPath = [self mainPathForRect:rect];
        UIBezierPath *fromShadowPath = [self shadowPathForRect:rect];
        
        UIBezierPath *newPath = [self mainPathForRect:[self fullRect]];
        UIBezierPath *shadowPath = [self shadowPathForRect:[self fullRect]];
        
        CABasicAnimation *opacity = [self basicAnimationWithKeyPath:@"opacity" toValue:@(1.0) duration:self.presentAnimationDuration];
        
        CABasicAnimation *pathAnimation = [self basicAnimationWithKeyPath:@"path" toValue:(__bridge id _Nullable)(newPath.CGPath) duration:self.presentAnimationDuration];
        pathAnimation.fromValue = (__bridge id _Nullable)(fromPath.CGPath);
        
        CABasicAnimation *shadowPathAnimation = [self basicAnimationWithKeyPath:@"shadowPath" toValue:(__bridge id _Nullable)(shadowPath.CGPath) duration:self.presentAnimationDuration];
        shadowPathAnimation.fromValue = (__bridge id _Nullable)(fromShadowPath.CGPath);
        
        CAAnimationGroup *animation = [self animationGroup:@[opacity, pathAnimation, shadowPathAnimation]];
        animation.removedOnCompletion = YES;
        
        animation.delegate = self;
        
        [self.dot addAnimation:animation forKey:@"initial"];
        
    } else {
        [self show];
    }
}

- (void)renderAnimations
{
    DDLogVerbose(@"");
    if (!__renderingAnimations)
    {
        if ([self.seekSlider isHidden] || [self.actionsView isHidden])
        {
            self.seekSlider.hidden = NO;
            self.actionsView.hidden = NO;
            self.muteButton.hidden = NO;
            __renderingAnimations = YES;
            [UIView animateWithDuration:0.5 animations:^{
                self.seekSlider.center = CGPointApplyAffineTransform(self.seekSlider.center, CGAffineTransformMakeTranslation(0,2*sliderHeight));
                self.actionsView.center = CGPointApplyAffineTransform(self.actionsView.center, CGAffineTransformMakeTranslation(-100, 0));
                self.muteButton.center = CGPointApplyAffineTransform(self.muteButton.center, CGAffineTransformMakeTranslation(100, 0));
            } completion:^(BOOL finished) {
                __renderingAnimations = NO;
            }];
            
            [self setupTimers];
        }
    }
}

- (void)removeAnimations
{
    DDLogDebug(@"");
    if (!__renderingAnimations)
    {
        if (![self.seekSlider isHidden] || ![self.actionsView isHidden])
        {
            __renderingAnimations = YES;
            [UIView animateWithDuration:0.5 animations:^{
                self.seekSlider.center = CGPointApplyAffineTransform(self.seekSlider.center, CGAffineTransformMakeTranslation(0,-2*sliderHeight));
                self.actionsView.center = CGPointApplyAffineTransform(self.actionsView.center, CGAffineTransformMakeTranslation(100, 0));
                self.muteButton.center = CGPointApplyAffineTransform(self.muteButton.center, CGAffineTransformMakeTranslation(-100, 0));
            } completion:^(BOOL finished) {
                self.seekSlider.hidden = finished;
                self.actionsView.hidden = finished;
                self.muteButton.hidden = finished;
                __renderingAnimations = NO;
            }];
            
            [self removeTimers];
        }
    }
}

- (void)__renderMore
{
    CAKeyframeAnimation *trans = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    trans.values = @[@(0),@(5),@(-2.0),@(3),@(0)];
    trans.keyTimes = @[@(0.0),@(0.35),@(0.70),@(0.90),@(1)];
    trans.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :1.8 :1 :1];
    trans.duration = 2.0;
    trans.additive = YES;
    trans.repeatCount = INFINITY;
    trans.beginTime = CACurrentMediaTime() + 2.0;
    trans.removedOnCompletion = NO;
    trans.fillMode = kCAFillModeForwards;
    [self.arrow.layer addAnimation:trans forKey:@"bouncing"];
}

- (IBAction)handleSoundAction:(id)sender
{
    [self removeTimers];
    BOOL currentState = self.muteButton.isSelected;
    
    self.extendedVideo.muted = !currentState;
    
    [self.muteButton setSelected:!currentState];
    [self setupTimers];
}

#pragma mark - Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.dot)
    {
        UIBezierPath *newPath = [self mainPathForRect:[self fullRect]];
        UIBezierPath *shadowPath = [self shadowPathForRect:[self fullRect]];
        
        self.dot.opacity = 1.0;
        self.dot.path = newPath.CGPath;
        self.dot.shadowPath = shadowPath.CGPath;
        
        [self.dot removeAnimationForKey:@"initial"];
        self.view.userInteractionEnabled = true;
        
        [self show];
    }
}

#pragma mark - Player

- (void)readyToPlay
{
    DDLogDebug(@"%lu", (unsigned long)self.parentViewController.parentViewController.scrollPageIndex);
    
    [self show];
}

- (void)failToLoadItem:(NSError*)error
{
    DDLogError(@"%@",error.description);
    [_waveView stopAnimating];
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
    [_waveView startAnimating];
}

- (void)bufferReady
{
    DDLogVerbose(@"");
    [_waveView stopAnimating];
}

- (void)networkFail:(NSError *)error
{
    DDLogError(@"");
    [_waveView stopAnimating];
}

#pragma mark - Displayable Protocol

- (void)show
{
    if (self.extendedVideo.status == AVPlayerStatusReadyToPlay)
    {
        DDLogVerbose(@"");
        [_waveView stopAnimating];
        
        [self.seekSlider setPlayer:self.extendedVideo];
        
        if (__hasAppeared)
        {
            [self.extendedVideo play];
            
            [self setupObservers];
            [self renderAnimations];
        }
    }
    else
    {
        [self.extendedVideo changePriority:BCPriorityPlay];
    }
}

- (void)setupObservers
{
    DDLogVerbose(@"");
    if (!__playEndObserver)
    {
        __weak typeof(self) welf = self;
        __playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.extendedVideo.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf.extendedVideo seekToTime:kCMTimeZero];
            welf.extendedVideo.muted = YES;
            [welf.muteButton setSelected:YES];
            [welf.extendedVideo play];
            
            [welf renderAnimations];
        }];
    }
    
    [self setupTimers];
}

- (void)removeObservers
{
    DDLogVerbose(@"");
    if (__playEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:__playEndObserver];
        __playEndObserver = nil;
    }
    
    [self removeTimers];
}

- (void)setupTimers
{
    DDLogVerbose(@"");
    hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:kCAHideControls target:self selector:@selector(removeAnimations) userInfo:nil repeats:NO];
}

- (void)removeTimers
{
    DDLogVerbose(@"");
    if (hideControlsTimer)
    {
        if ([hideControlsTimer isValid])
        {
            [hideControlsTimer invalidate];
        }
        hideControlsTimer = nil;
    }
}

- (void)updateSecondsWatched
{
    float secondsWatched = CMTimeGetSeconds(self.extendedVideo.currentTime);
    DDLogVerbose(@"User saw %@ during %f", self.product.id, secondsWatched);
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 postUserWatchedVideoWithID:self.product.id withType:Li5VideoTypeFull during:[NSNumber numberWithFloat:secondsWatched] inContext:Li5ContextDiscover withCompletion:^(NSError *error) {
        if (error)
        {
            DDLogError(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Gesture Recognizers

- (void)handleLockTap:(UIPanGestureRecognizer *)gr
{
    if (self.dot)
    {
        switch (gr.state) {
            case UIGestureRecognizerStateChanged:
            {
                CGPoint current = [gr translationInView:self.view];
                double h = MAX(([self diameter]) - current.y * 3, 10);
                CGSize size = CGSizeMake(h, h);
                
                CGRect newRect = [self center:CGRectMake(0, 0,size.width, size.height) in:self.view.bounds];
                self.dot.path = [self mainPathForRect:newRect].CGPath;
                self.dot.shadowPath = [self shadowPathForRect:newRect].CGPath;
                
                break;
            }
            case UIGestureRecognizerStateEnded:
            {
                CGPoint current = [gr translationInView:self.view];
                
                if (current.y > [self threshold])
                {
                    [self.parentViewController performSelectorOnMainThread:@selector(handleLockTap:) withObject:gr waitUntilDone:NO];
                    [self.extendedVideo changePriority:BCPriorityUnLock];
                    [self.extendedVideo seekToTime:kCMTimeZero];
                    [self.muteButton setSelected:NO];
                    self.extendedVideo.muted = NO;
                    __locked = YES;
                }
                else
                {
                    UIBezierPath *newPath = [self mainPathForRect:[self fullRect]];
                    UIBezierPath *shadowPath = [self shadowPathForRect:[self fullRect]];
                    
                    CABasicAnimation *opacity = [self basicAnimationWithKeyPath:@"opacity" toValue:@(1.0) duration:0.1];
                    
                    CABasicAnimation *pathAnimation = [self basicAnimationWithKeyPath:@"path" toValue:(__bridge id _Nullable)(newPath.CGPath) duration:0.1];
                    
                    CABasicAnimation *shadowPathAnimation = [self basicAnimationWithKeyPath:@"shadowPath" toValue:(__bridge id _Nullable)(shadowPath.CGPath) duration:0.1];
                    
                    CAAnimationGroup *animation = [self animationGroup:@[opacity, pathAnimation, shadowPathAnimation]];
                    animation.removedOnCompletion = YES;
                    
                    [self.dot addAnimation:animation forKey:nil];
                    
                    self.dot.path = newPath.CGPath;
                    self.dot.shadowPath = shadowPath.CGPath;
                    self.dot.opacity = 1.0;
                }
                
                break;
            }
            case UIGestureRecognizerStateCancelled:
            {
                self.dot.path = [self mainPathForRect:self.fullRect].CGPath;
                self.dot.shadowPath = [self shadowPathForRect:self.fullRect].CGPath;
                self.dot.opacity = 1.0;
                break;
            }
            default:
                break;
        }
    }
}

- (void)handleSimpleTap:(UIGestureRecognizer *)sender
{
    DDLogVerbose(@"");
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (self.actionsView.hidden)
        {
            [self renderAnimations];
        }
        else
        {
            [self removeAnimations];
        }
    }
}

- (void)setupGestureRecognizers
{
    _simpleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSimpleTap:)];
    [self.view addGestureRecognizer:_simpleTapGestureRecognizer];
    
    _lockPanGestureRecognzier = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLockTap:)];
    _lockPanGestureRecognzier.delegate = self;
    _lockPanGestureRecognzier.cancelsTouchesInView = NO;
    _lockPanGestureRecognzier.maximumNumberOfTouches = 1;
    _lockPanGestureRecognzier.minimumNumberOfTouches = 1;
    
    [self.view addGestureRecognizer:_lockPanGestureRecognzier];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touch = [gestureRecognizer locationInView:self.view];
    if (gestureRecognizer == _lockPanGestureRecognzier)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
        return (touch.y >= sliderHeight) && (fabs(degree) > 70.0) && (velocity.y > 0);
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if([[gestureRecognizer view] isKindOfClass:[UIScrollView class]])
    {
        if (otherGestureRecognizer == _lockPanGestureRecognzier)
        {
            return YES;
        }
    }
    return NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removeTimers];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removeTimers];
    [super touchesEnded:touches withEvent:event];
    [self setupTimers];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removeTimers];
    [super touchesCancelled:touches withEvent:event];
    [self setupTimers];
}

#pragma mark - Private Methods

- (CGRect)center:(CGRect)rect in:(CGRect)container
{
    CGPoint containerCenter = CGPointMake(container.origin.x + container.size.width / 2, container.origin.y + container.size.height / 2);
    
    rect.origin = CGPointMake( containerCenter.x - rect.size.width / 2, containerCenter.y - rect.size.height / 2);
    return rect;
}

- (CGFloat)threshold
{
    return [UIScreen mainScreen].bounds.size.height * self.dismissThreshold;
}

- (CGFloat)diameter
{
    CGSize bounds = self.view.bounds.size;
    return sqrt(bounds.width * bounds.width + bounds.height * bounds.height);
}

- (CGRect)fullRect
{
    CGFloat h = [self diameter];
    CGSize size = CGSizeMake(h,h);
    return [self center:CGRectMake(0, 0,size.width, size.height) in:self.view.bounds];
}

- (UIBezierPath*)mainPathForRect:(CGRect)rect
{
    return [[UIBezierPath bezierPathWithOvalInRect:rect] bezierPathByReversingPath];
}

- (UIBezierPath*)shadowPathForRect:(CGRect)rect
{
    return [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, -10, -10)] bezierPathByReversingPath];
}

- (CAAnimationGroup*)animationGroup:(NSArray<CAAnimation*>*)animations
{
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = animations;
    animation.duration = [[animations valueForKeyPath:@"@max.duration"] doubleValue];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

- (CABasicAnimation*)basicAnimationWithKeyPath:(NSString*)keyPath toValue:(id)value duration:(CFTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.toValue = value;
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    return animation;
}

#pragma mark - Device Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [self removeObservers];
    [_extendedVideo pauseAndDestroy];
}

@end
