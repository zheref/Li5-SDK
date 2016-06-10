//
//  UnlockedViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "Li5PlayerUISlider.h"
#import "PrimeTimeViewController.h"
#import "UnlockedViewController.h"
#import "ProductPageViewController.h"
#import "ProductPageActionsView.h"

static const CGFloat sliderHeight = 50.0;

@interface UnlockedViewController ()
{
    id __playEndObserver;
    NSTimer *hideControlsTimer;

    UIPanGestureRecognizer *_lockPanGestureRecognzier;
    UITapGestureRecognizer *_simpleTapGestureRecognizer;
}

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) BCPlayer *extendedVideo;
@property (weak, nonatomic) IBOutlet Li5PlayerUISlider *seekSlider;
@property (weak, nonatomic) IBOutlet ProductPageActionsView *actionsView;

@end

@implementation UnlockedViewController

@synthesize product;

- (id)initWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx
{
    UIStoryboard *productPageStoryboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle mainBundle]];
    self = [productPageStoryboard instantiateViewControllerWithIdentifier:@"UnlockedView"];
    if (self)
    {
        self.product = thisProduct;
        NSURL *videoUrl = [NSURL URLWithString:self.product.videoURL];
        DDLogVerbose(@"Creating Full Video Player Layer for: %@", [videoUrl lastPathComponent]);
        _extendedVideo = [[BCPlayer alloc] initWithUrl:videoUrl bufferInSeconds:20.0 priority:BCPriorityNormal delegate:self];
    }
    return self;
}

#pragma mark - UI View

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    BCPlayerLayer *playerLayer = [[BCPlayerLayer alloc] initWithPlayer:self.extendedVideo andFrame:self.view.bounds];
    playerLayer.frame = self.view.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.playerView.layer addSublayer:playerLayer];

    [self.actionsView setProduct:self.product];
    
    [self setupGestureRecognizers];
    
    [self renderAnimations];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
    
    [self.extendedVideo pause];
    
    [self removeObservers];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    [self show];
}

- (void)renderAnimations
{
    DDLogVerbose(@"rendering animations for unlocked video");
    if ([self.seekSlider isHidden] || [self.actionsView isHidden])
    {
        DDLogVerbose(@"seek slider center: %@",NSStringFromCGPoint(self.seekSlider.center));
        self.seekSlider.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.seekSlider.center = CGPointApplyAffineTransform(self.seekSlider.center, CGAffineTransformMakeTranslation(0,2*sliderHeight));
        }];
        
        DDLogVerbose(@"actions view center: %@",NSStringFromCGPoint(self.actionsView.center));
        self.actionsView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.actionsView.center = CGPointApplyAffineTransform(self.actionsView.center, CGAffineTransformMakeTranslation(-100, 0));
        }];
    }
}

- (void)removeAnimations
{
    DDLogDebug(@"");
    if (![self.seekSlider isHidden] || ![self.actionsView isHidden])
    {
        DDLogVerbose(@"seek slider center: %@",NSStringFromCGPoint(self.seekSlider.center));
        [UIView animateWithDuration:0.5 animations:^{
            self.seekSlider.center = CGPointApplyAffineTransform(self.seekSlider.center, CGAffineTransformMakeTranslation(0,-2*sliderHeight));
        } completion:^(BOOL finished) {
            self.seekSlider.hidden = finished;
        }];
        DDLogVerbose(@"actions view center: %@",NSStringFromCGPoint(self.actionsView.center));
        [UIView animateWithDuration:0.5 animations:^{
            self.actionsView.center = CGPointApplyAffineTransform(self.actionsView.center, CGAffineTransformMakeTranslation(100, 0));
        } completion:^(BOOL finished) {
            self.actionsView.hidden = finished;
        }];
        
        [self removeTimers];
    }
}

#pragma mark - Player

- (void)readyToPlay
{
    DDLogDebug(@"Ready to play extended for: %lu", (unsigned long)[((ProductPageViewController*)self.parentViewController.parentViewController) index]);
    
    //[self show];
}

- (void)failToLoadItem
{
    DDLogVerbose(@"");
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
}

#pragma mark - Displayable Protocol

- (void)hideAndMoveToViewController:(UIViewController *)viewController
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

    [self removeObservers];
    [self.extendedVideo pauseAndDestroy];
}

- (void)show
{
    if (self.extendedVideo.status == AVPlayerStatusReadyToPlay &&
        self.parentViewController.parentViewController != nil &&
        self.parentViewController.parentViewController == [((PrimeTimeViewController *)self.parentViewController.parentViewController.parentViewController).viewControllers firstObject])
    {
        DDLogVerbose(@"Show %@.", [[(AVURLAsset *)self.extendedVideo.currentItem.asset URL] lastPathComponent]);

        [self.extendedVideo play];
        [self.seekSlider setPlayer:self.extendedVideo];
        
        [self setupObservers];
        [self renderAnimations];
    }
}

- (void)setupObservers
{
    if (!__playEndObserver)
    {
        __weak typeof(self) welf = self;
        __playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.extendedVideo.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf.extendedVideo seekToTime:kCMTimeZero];
            [welf renderAnimations];
        }];
    }
    
    [self setupTimers];
}

- (void)removeObservers
{
    if (__playEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:__playEndObserver];
        __playEndObserver = nil;
    }
    
    [self removeTimers];
}

- (void)setupTimers
{
    hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeAnimations) userInfo:nil repeats:NO];
}

- (void)removeTimers
{
    if (hideControlsTimer)
    {
        if ([hideControlsTimer isValid])
        {
            [hideControlsTimer invalidate];
        }
        hideControlsTimer = nil;
    }
}

#pragma mark - Gesture Recognizers

- (void)handleLockTap:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint distance = [(UIPanGestureRecognizer*)recognizer translationInView:recognizer.view];
        if (distance.y > 15)
        {
            [self.parentViewController performSelectorOnMainThread:@selector(handleLockTap:) withObject:recognizer waitUntilDone:NO];
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
        return (touch.y >= sliderHeight) && (fabs(degree) > 20.0) && (velocity.y > 0);
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
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removeTimers];
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark - Device Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DDLogDebug(@"");
    [self removeObservers];
    _extendedVideo = nil;
}

@end
