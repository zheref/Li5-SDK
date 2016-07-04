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

static const CGFloat sliderHeight = 50.0;
static const CGFloat kCAHideControls = 4.0;

@interface UnlockedViewController ()
{
    id __playEndObserver;
    NSTimer *hideControlsTimer;

    UIPanGestureRecognizer *_lockPanGestureRecognzier;
    UITapGestureRecognizer *_simpleTapGestureRecognizer;
    
    BOOL __hasAppeared;
    BOOL __renderingAnimations;
}

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) BCPlayer *extendedVideo;
@property (weak, nonatomic) IBOutlet Li5PlayerUISlider *seekSlider;
@property (weak, nonatomic) IBOutlet ProductPageActionsView *actionsView;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;

@end

@implementation UnlockedViewController

@synthesize product;

+ (id)unlockedWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx;
{
    UIStoryboard *productPageStoryboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle mainBundle]];
    UnlockedViewController *newSelf = [productPageStoryboard instantiateViewControllerWithIdentifier:@"UnlockedView"];
    if (newSelf)
    {
        DDLogVerbose(@"%@", thisProduct.id);
        newSelf.product = thisProduct;
        NSURL *videoUrl = [NSURL URLWithString:newSelf.product.videoURL];
        newSelf.extendedVideo = [[BCPlayer alloc] initWithUrl:videoUrl bufferInSeconds:20.0 priority:BCPriorityNormal delegate:newSelf];
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
    // Do any additional setup after loading the view.
    BCPlayerLayer *playerLayer = [[BCPlayerLayer alloc] initWithPlayer:self.extendedVideo andFrame:self.view.bounds];
    playerLayer.frame = self.view.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.playerView.layer addSublayer:playerLayer];

    [self.actionsView setProduct:self.product];
    
    [self setupGestureRecognizers];
    
    [self renderAnimations];
    
    [self __renderMore];
    
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
    
    [self show];
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
    BOOL currentState = self.muteButton.isSelected;
    
    self.extendedVideo.muted = !currentState;
    
    [self.muteButton setSelected:!currentState];
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
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
}

- (void)networkFail:(NSError *)error
{
    DDLogError(@"");
}

#pragma mark - Displayable Protocol

- (void)show
{
    if (self.extendedVideo.status == AVPlayerStatusReadyToPlay && __hasAppeared)
    {
        DDLogVerbose(@"%@.", [[(AVURLAsset *)self.extendedVideo.currentItem.asset URL] lastPathComponent]);

        [self.extendedVideo play];
        [self.seekSlider setPlayer:self.extendedVideo];
        
        [self setupObservers];
        [self renderAnimations];
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

- (void)handleLockTap:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint distance = [(UIPanGestureRecognizer*)recognizer translationInView:recognizer.view];
        if (distance.y > 15)
        {
            [self.parentViewController performSelectorOnMainThread:@selector(handleLockTap:) withObject:recognizer waitUntilDone:NO];
            [self.extendedVideo seekToTime:kCMTimeZero];
            [self.muteButton setSelected:NO];
            self.extendedVideo.muted = NO;
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
    DDLogDebug(@"%p",self);
    [self removeObservers];
    _extendedVideo = nil;
}

@end
