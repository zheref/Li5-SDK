//
//  ViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import BCVideoPlayer;

#import "ShapesHelper.h"
#import "TeaserViewController.h"
#import "ProductPageViewController.h"
#import "ProductsViewController.h"
#import "UserProfileDynamicInteractor.h"
#import "ExploreDynamicInteractor.h"
#import "Li5PlayerTimer.h"
#import "ProductPageActionsView.h"
#import "Li5Constants.h"
#import "Li5VolumeView.h"
#import "Li5-Swift.h"

#pragma mark - Class Definitions

@interface TeaserViewController ()
{
    id playEndObserver;
    
    UIPanGestureRecognizer *profilePanGestureRecognizer;
    UIPanGestureRecognizer *searchPanGestureRecognizer;
    UIPanGestureRecognizer *backToSearchPanGestureRecognzier;
    UILongPressGestureRecognizer *longTapGestureRecognizer;
    id<UserProfileViewControllerPanTargetDelegate> profileInteractor;
    id<ExploreViewControllerPanTargetDelegate> searchInteractor;
    
    BOOL __hasUnlockedVideo;
    BOOL __hasAppeared;
}

@property (assign, nonatomic) ProductContext pContext;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (nonatomic, strong) BCPlayer *teaserPlayer;
@property (weak, nonatomic) IBOutlet Li5PlayerTimer *playerTimer;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;
@property (weak, nonatomic) IBOutlet ProductPageActionsView *actionsView;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;

@property (strong, nonatomic) Wave *waveView;

@end

@implementation TeaserViewController

@synthesize product, previousViewController, nextViewController;

#pragma mark - Init

+ (id)teaserWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx
{
    UIStoryboard *productPageStoryboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle mainBundle]];
    TeaserViewController *newSelf = [productPageStoryboard instantiateViewControllerWithIdentifier:@"TeaserView"];
    if (newSelf)
    {
        DDLogVerbose(@"%@", thisProduct.id);
        newSelf.product = thisProduct;
        newSelf.pContext = ctx;
        
        [newSelf initialize];
    }
    return newSelf;
}

- (void)initialize
{
    DDLogVerbose(@"");
    __hasUnlockedVideo = (self.product.videoURL != nil && ![self.product.videoURL isEqualToString:@""]);
    
    NSURL *playerUrl = [NSURL URLWithString:self.product.trailerURL];
    _teaserPlayer = [[BCPlayer alloc] initWithUrl:playerUrl bufferInSeconds:20.0 priority:BCPriorityNormal delegate:self];
    //AVPlayer *player = [[AVPlayer alloc] initWithURL:playerUrl];
}

#pragma mark - UI View

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    DDLogVerbose(@"%@", self.product.id);
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    BCPlayerLayer *playerLayer = [[BCPlayerLayer alloc] initWithPlayer:_teaserPlayer andFrame:self.view.bounds];
    playerLayer.frame = self.view.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.playerView.layer addSublayer:playerLayer];
    
    [self.playerTimer setHasUnlocked:__hasUnlockedVideo];
    [self.actionsView setProduct:self.product];
    
    self.categoryLabel.text = [self.product.categoryName uppercaseString];
    self.categoryImage.image = [UIImage imageNamed:[[self.product.categoryName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString]];
    
    self.categoryImage.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    self.categoryImage.layer.shadowOffset = CGSizeMake(0, 2);
    self.categoryImage.layer.shadowOpacity = 1;
    self.categoryImage.layer.shadowRadius = 1.0;
    self.categoryImage.clipsToBounds = NO;
    
    self.logoView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    if (self.pContext != kProductContextDiscover)
    {
        CALayer *contextLayer = [[CALayer alloc] init];
        contextLayer.backgroundColor = [UIColor li5_redColor].CGColor;
        contextLayer.frame = CGRectMake(0,0,self.view.frame.size.width,5);
        [self.view.layer addSublayer:contextLayer];
        
        self.logoView.hidden = TRUE;
    }
    
    _waveView = [[Wave alloc] initWithView:self.view];
    [self.view addSubview:_waveView];
    [_waveView startAnimating];
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
    
    [self setupGestureRecognizers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogDebug(@"");
    [super viewDidDisappear:animated];
    
    __hasAppeared = NO;
    
    [self.teaserPlayer pause];
    [self removeObservers];
    
    [self updateSecondsWatched];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogDebug(@"");
    [super viewDidAppear:animated];
    
    __hasAppeared = YES;
    
    [self show];
}

#pragma mark - Players

- (void)replayMovie:(NSNotification *)notification
{
    DDLogVerbose(@"");
    [self redisplay];
}

- (void)readyToPlay
{
    DDLogDebug(@"%lu", (unsigned long)self.parentViewController.parentViewController.scrollPageIndex);
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kPrimeTimeLoaded object:nil];
    
    [self show];
}

- (void)failToLoadItem:(NSError*)error
{
    DDLogError(@"%@",error.description);
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kPrimeTimeFailedToLoad object:nil];
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
    if (self.teaserPlayer.status == AVPlayerStatusReadyToPlay)
    {
        [_waveView stopAnimating];
        [_waveView removeFromSuperview];
        
        [self.playerTimer setPlayer:self.teaserPlayer];
        
        if(__hasAppeared)
        {
            DDLogVerbose(@"");
            [self.teaserPlayer play];
            
            [self renderAnimations];
            [self setupObservers];
            
        }
    }
    else
    {
        [self.teaserPlayer changePriority:BCPriorityHigh];
    }
}

- (void)redisplay
{
    DDLogVerbose(@"");
    [self.teaserPlayer seekToTime:kCMTimeZero];
    [self.teaserPlayer play];
}

- (void)removeObservers
{
    if (playEndObserver)
    {
        DDLogVerbose(@"");
        [[NSNotificationCenter defaultCenter] removeObserver:playEndObserver];
        playEndObserver = nil;
    }
}

- (void)setupObservers
{
    if (!playEndObserver)
    {
        DDLogVerbose(@"");
        __weak typeof(id) welf = self;
        playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.teaserPlayer.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf replayMovie:note];
        }];
    }
}

- (void)updateSecondsWatched
{
    float secondsWatched = CMTimeGetSeconds(self.teaserPlayer.currentTime);
    DDLogVerbose(@"%@:%f", self.product.id, secondsWatched);
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 postUserWatchedVideoWithID:self.product.id withType:Li5VideoTypeTrailer during:[NSNumber numberWithFloat:secondsWatched] inContext:Li5ContextDiscover withCompletion:^(NSError *error) {
        if (error)
        {
            DDLogError(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - User Actions

- (void)userDidPan:(UIPanGestureRecognizer*)gestureRecognizer
{
    [searchInteractor userDidPan:gestureRecognizer];
}

- (IBAction)userDidTap:(UITapGestureRecognizer*)sender
{
    DDLogVerbose(@"");
    if (__hasUnlockedVideo)
    {
        UIViewController *modalView = [self.storyboard instantiateViewControllerWithIdentifier:@"TapAndHoldToUnlockView"];
        modalView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        [self presentViewController:modalView animated:NO completion:^{
            //Nothing for now
        }];
    }
}

- (void)handleLongTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        //Long Tap transparent Background Rectangle
        CGFloat animationDuration = 0.5f;
        CGFloat fromRadius = 50.0f;
        CGFloat toRadius = 800.0f;

        CGPoint touchPosition = [sender locationInView:self.view];

        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(touchPosition.x, touchPosition.y, 100, 100)];
        circleView.alpha = 0.2;
        circleView.center = touchPosition;
        circleView.layer.cornerRadius = fromRadius;
        circleView.backgroundColor = [UIColor blackColor];

        [self.view addSubview:circleView];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:fromRadius];
        animation.toValue = [NSNumber numberWithFloat:toRadius];
        animation.duration = animationDuration;
        animation.fillMode = kCAFillModeBoth;
        circleView.layer.cornerRadius = toRadius;
        [circleView.layer addAnimation:animation forKey:@"cornerRadius"];

        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
          circleView.frame = CGRectMake(-800, -500, 2 * toRadius, 2 * toRadius);
        }
            completion:^(BOOL finished) {
              [circleView removeFromSuperview];
            }];

        [self.parentViewController performSelectorOnMainThread:@selector(handleLongTap:) withObject:sender waitUntilDone:NO];
    }
}

- (void)goBackToSearch:(UIPanGestureRecognizer *)recognizer
{
    //TODO use Search interactor
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)showProfile:(UIButton*)sender
{
    [profileInteractor presentViewWithCompletion:nil];
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers
{
    //Unlock Video Long Tap Gesture Recognizer - Tap & Hold
    if (__hasUnlockedVideo)
    {
        longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        longTapGestureRecognizer.minimumPressDuration = 1.0f;
        longTapGestureRecognizer.allowableMovement = 100.0f;
        
        [self.view addGestureRecognizer:longTapGestureRecognizer];
    }
    
    //User Profile Gesture Recognizer - Swipe Down from 0-100px
    profileInteractor = [[UserProfileDynamicInteractor alloc] initWithParentViewController:self];
    searchInteractor = [[ExploreDynamicInteractor alloc] initWithParentViewController:self];
    
    if (self.pContext == kProductContextDiscover)
    {
        //Profile Gesture Recognizer - Swipe Down from 0-100px
        profilePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:profileInteractor action:@selector(userDidPan:)];
        [profilePanGestureRecognizer setDelegate:self];
        [self.view addGestureRecognizer:profilePanGestureRecognizer];
        
        //Search Products Gesture Recognizer - Swipe Down from below 100px
        searchPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
        [searchPanGestureRecognizer setDelegate:self];
        [self.view addGestureRecognizer:searchPanGestureRecognizer];
    }
    else
    {
        backToSearchPanGestureRecognzier = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(goBackToSearch:)];
        backToSearchPanGestureRecognzier.delegate = self;
        [self.view addGestureRecognizer:backToSearchPanGestureRecognzier];
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touch = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (gestureRecognizer == profilePanGestureRecognizer)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        return (touch.y < 150) && (velocity.y > 0);
    }
    else if (gestureRecognizer == searchPanGestureRecognizer)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
        return (touch.y >= 150) && (fabs(degree) > 70.0) && (velocity.y > 0);
    }
    else if (gestureRecognizer == backToSearchPanGestureRecognzier)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
        return (fabs(degree) > 70.0) && (velocity.y > 0);
    }
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([[gestureRecognizer view] isKindOfClass:[UIScrollView class]])
    {
        if (otherGestureRecognizer == profilePanGestureRecognizer || otherGestureRecognizer == searchPanGestureRecognizer)
        {
            return YES;
        }
    }
    return (gestureRecognizer == profilePanGestureRecognizer &&
            (otherGestureRecognizer == searchPanGestureRecognizer || otherGestureRecognizer == backToSearchPanGestureRecognzier));
}

#pragma mark - Animations

- (void)removeAnimations
{
//    if ([removableItems count] > 0)
//    {
//        DDLogVerbose(@"removing animations");
//        [removableItems makeObjectsPerformSelector:@selector(removeAllAnimations)];
//        [removableItems makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//        [removableItems removeAllObjects];
//        progressLayer = nil;
//        timeText = nil;
//        [self.view setNeedsDisplay];
//    }
}

- (void)renderAnimations
{
    DDLogVerbose(@"");
    [self removeAnimations];
    
    [self __renderCategory];
    
    [self __renderMore];
    
}

- (void)__renderCategory
{
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

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [self removeObservers];
    _teaserPlayer = nil;
}

@end