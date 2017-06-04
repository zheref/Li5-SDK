//
//  LastPageViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/27/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "ExploreDynamicInteractor.h"
#import "LastPageViewController.h"
#import "Li5Constants.h"
#import "Li5VolumeView.h"
#import "UserProfileDynamicInteractor.h"

@interface LastPageViewController ()
{
    UIPanGestureRecognizer *profilePanGestureRecognizer;
    UIPanGestureRecognizer *searchPanGestureRecognizer;
    id<UserProfileViewControllerPanTargetDelegate> profileInteractor;
    id<ExploreViewControllerPanTargetDelegate> searchInteractor;
    
    id __playerEndObserver;
    BOOL __hasAppeared;
    id __showPlayerEndObserver;
}

@property (weak, nonatomic) IBOutlet UIView *staticView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *closeMessage;
@property (weak, nonatomic) IBOutlet UIView *swipeDownView;
@property (weak, nonatomic) IBOutlet UIButton *turnOnNotifications;
@property (weak, nonatomic) IBOutlet UIImageView *dropDownArrow;

@property (weak, nonatomic) IBOutlet UIImageView *popcorn1;
@property (weak, nonatomic) IBOutlet UIImageView *popcorn2;
@property (weak, nonatomic) IBOutlet UIImageView *popcornFloor;
@property (weak, nonatomic) IBOutlet UIImageView *popcorn3;
@property (weak, nonatomic) IBOutlet UIImageView *popcorn4;

@property (nonatomic, strong) BCPlayer *player;
@property (nonatomic, strong) BCPlayerLayer *playerLayer;
@property (nonatomic, strong) AVAudioPlayer* audioPlayer;

@property (weak, nonatomic) IBOutlet UIView *endOfShowView;
@property (nonatomic, strong) AVPlayer *showPlayer;
@property (weak, nonatomic) IBOutlet UIView *endOfShowVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *showLogo;

@end

@implementation LastPageViewController

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
    
}

#pragma mark - Public Methods

- (void)setLastVideoURL:(EndOfPrimeTime *)endOfPrimeTime
{
    _lastVideoURL = endOfPrimeTime;
    
    _player = [[BCPlayer alloc] initWithUrl:[NSURL URLWithString:endOfPrimeTime.url] bufferInSeconds:50.0 priority:BCPriorityPlay delegate:self];
    _playerLayer = [[BCPlayerLayer alloc] initWithPlayer:_player andFrame:[UIScreen mainScreen].bounds previewImageRequired:YES];
    
    __weak typeof(self) welf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSData *posterData = [[NSData alloc] initWithBase64EncodedString:endOfPrimeTime.poster options:0];
        UIImage *posterImage = [UIImage imageWithData:posterData];
        UIImageView *posterImageView = [[UIImageView alloc] initWithImage:posterImage];
        posterImageView.frame = welf.view.bounds;
        [welf.videoView insertSubview:posterImageView atIndex:0];
    }];
}

#pragma mark - UI Setup

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.staticView.hidden = YES;
    
    _playerLayer.frame = self.view.bounds;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.videoView.layer addSublayer:_playerLayer];

//    NSString *goToExploreSoundURL = [[NSBundle mainBundle] pathForResource:@"go_to_explore" ofType:@"mp3"];
//    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:goToExploreSoundURL] error:nil];
//    [_audioPlayer setNumberOfLoops:0];
//    [_audioPlayer prepareToPlay];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kPrimeTimeLoaded object:nil];
    
    [self setupGestureRecognizers];
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
    
#if FULL_VERSION
    self.closeMessage.text = NSLocalizedString(@"SWIPE DOWN TO EXPLORE MORE",nil);
#endif
    
    [self updateNotificationsViews];
    
#ifdef EMBED
    self.showLogo.image = [self.showLogo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.showLogo.tintColor = [UIColor li5_whiteColor];
    
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"end_of_show" withExtension:@".mp4"];
    self.showPlayer = [[AVPlayer alloc] initWithURL:videoURL];
    self.showPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.showPlayer.muted = TRUE;
    
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.showPlayer];
    videoLayer.frame = self.view.bounds;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.endOfShowVideoView.layer addSublayer:videoLayer];
    
    self.staticView.hidden = YES;
    self.swipeDownView.hidden = YES;
#else
    self.endOfShowView.hidden = YES;
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"");
    [super viewWillAppear:animated];
    
    [self updateNotificationsViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    __hasAppeared = YES;
    
    [self readyToPlay];
    [self setupObservers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
 
    __hasAppeared = NO;
    
    [self.player pause];
    [self removeObservers];
    
    self.staticView.hidden = (self.player!=nil);
}

- (void)updateNotificationsViews {
    DDLogVerbose(@"");
    if ([self notificationsEnabled]) {
        self.turnOnNotifications.hidden = YES;
        self.dropDownArrow.hidden = YES;
        for (UIView *v in @[_popcorn1, _popcorn2, _popcorn3, _popcorn4, _popcornFloor]) {
            v.hidden = NO;
        }
    } else {
        self.turnOnNotifications.hidden = NO;
        self.dropDownArrow.hidden = NO;
        for (UIView *v in @[_popcorn1, _popcorn2, _popcorn3, _popcorn4, _popcornFloor]) {
            v.hidden = YES;
        }
        [self __bounce:self.dropDownArrow];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)notificationsEnabled {
    return YES;
}

- (void)presentSwipeDownViewIfNeeded
{
    DDLogVerbose(@"");
    [self removeObservers];
    
#ifndef EMBED
#if FULL_VERSION
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kLi5SwipeDownExplainerViewPresented])
    {
        [_audioPlayer play];
        self.swipeDownView.hidden = NO;
        [self hideVideo];
    }
    else
    {
        [_audioPlayer play];
        [self hideVideo];
        [self.view bringSubviewToFront:self.staticView];
    }
#else
    [_audioPlayer play];
    [self hideVideo];
    [self.view bringSubviewToFront:self.staticView];
#endif
#else
    [_audioPlayer play];
    [self hideVideo];
    [self.showPlayer play];
    [self setupObservers];
#endif
}

- (void)__bounce:(UIView *)view
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
    [view.layer addAnimation:trans forKey:@"bouncing"];
}


- (void)hideVideo
{
    if (_player)
    {
        self.staticView.hidden = NO;
        self.videoView.hidden = YES;
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        _player = nil;
    }
}

- (IBAction)doTurnOnNotifications:(id)sender {
    
}

- (void)replayEndOfShow {
    [self.showPlayer seekToTime:kCMTimeZero];
    [self.showPlayer play];
}

#pragma mark - Observers

- (void)setupObservers
{
    DDLogVerbose(@"");
    if (!__playerEndObserver && _player)
    {
        __weak typeof(self) welf = self;
        __playerEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf presentSwipeDownViewIfNeeded];
        }];
    }
    
    if (!__showPlayerEndObserver && _showPlayer) {
        __weak typeof(self) welf = self;
        __showPlayerEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.showPlayer.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf replayEndOfShow];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationsViews) name:kUserSettingsUpdated object:nil];
}

- (void)removeObservers
{
    DDLogVerbose(@"");
    if (__playerEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:__playerEndObserver];
        __playerEndObserver = nil;
    }
    
    if (__showPlayerEndObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:__showPlayerEndObserver];
        __showPlayerEndObserver = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Player

- (void)readyToPlay
{
    DDLogVerbose(@"");
//    if (self.player.status == AVPlayerStatusReadyToPlay)
//    {
        if (__hasAppeared && self.player != nil)
        {
            [self.player play];
        }
        else
        {
            self.staticView.hidden = NO;
//            [self presentSwipeDownViewIfNeeded];
        }
//    }
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
}

- (void)bufferReady
{
    DDLogVerbose(@"");
}

- (void)failToLoadItem:(NSError *)error
{
    DDLogError(@"%@",error.description);
    [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
}

- (void)networkFail:(NSError *)error
{
    DDLogError(@"%@",error.description);
    [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
}

#pragma mark - Gesture Recognizers

- (void)userDidPan:(UIPanGestureRecognizer *)recognizer {
    if (self.videoView.hidden) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            if (!self.swipeDownView.hidden) {
                self.swipeDownView.hidden = YES;
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:TRUE forKey:kLi5SwipeDownExplainerViewPresented];
                [self.view bringSubviewToFront:self.staticView];
            }
        }
        
        [searchInteractor userDidPan:recognizer];
    }
}

- (void)setupGestureRecognizers
{
    DDLogVerbose(@"");
//    //User Profile Gesture Recognizer - Swipe Down from 0-100px
//    profileInteractor = [[UserProfileDynamicInteractor alloc] initWithParentViewController:self];
//    profilePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:profileInteractor action:@selector(userDidPan:)];
//    [profilePanGestureRecognizer setDelegate:self];
//    [self.view addGestureRecognizer:profilePanGestureRecognizer];
    
#if FULL_VERSION
    //Search Products Gesture Recognizer - Swipe Down from below 100px
    searchPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    [searchPanGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:searchPanGestureRecognizer];
#endif
    
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
            (otherGestureRecognizer == searchPanGestureRecognizer));
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [self removeObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
