//
//  ViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import BCVideoPlayer;
@import pop;
@import TSMessages;
@import FBSDKCoreKit;
@import Intercom;

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
#import "Heap.h"

#import "PrimeTimeViewController.h"
#pragma mark - Class Definitions

@interface TeaserViewController ()
{
    id playEndObserver;
    id teaserActionsViewTimer;
    
    UIPanGestureRecognizer *profilePanGestureRecognizer;
    UIPanGestureRecognizer *searchPanGestureRecognizer;
    UIPanGestureRecognizer *backToSearchPanGestureRecognzier;
    UILongPressGestureRecognizer *longTapGestureRecognizer;
    id<UserProfileViewControllerPanTargetDelegate> profileInteractor;
    id<ExploreViewControllerPanTargetDelegate> searchInteractor;
    
    BOOL __hasUnlockedVideo;
    BOOL __hasAppeared;
    BOOL __actionsViewAppeared;
    BOOL __hasRetriedFailedItem;
    BOOL __hasDetails;
    
    double __startPositionX;
    double __endPositionX;
    double __space;
    
    TapAndHoldViewController *_modalView;
}

@property (assign, nonatomic) ProductContext pContext;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (nonatomic, strong) BCPlayer *teaserPlayer;
@property (nonatomic, strong) BCPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet Li5PlayerTimer *playerTimer;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;
@property (weak, nonatomic) IBOutlet ProductPageActionsView *actionsView;
@property (weak, nonatomic) IBOutlet UIButton *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
//@property (strong, nonatomic) UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *moreView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) Wave *waveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowLeadingMoreTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowVerticalCenter;
@property (weak, nonatomic) IBOutlet ThinPlayerProgressView *playerProgressLine;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

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
        DDLogVerbose(@"%p %@", newSelf, thisProduct.id);
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
    __hasDetails = [self.product.type caseInsensitiveCompare:@"product"] == NSOrderedSame || ([self.product.type caseInsensitiveCompare:@"url"] == NSOrderedSame && self.product.contentUrl != nil);
    
    __hasRetriedFailedItem = NO;
    
    NSURL *playerUrl = [NSURL URLWithString:self.product.trailerURL];
    _teaserPlayer = [[BCPlayer alloc] initWithUrl:playerUrl bufferInSeconds:10.0 priority:BCPriorityBuffer delegate:self];
    
    self.playerLayer = [[BCPlayerLayer alloc] initWithPlayer:_teaserPlayer andFrame:[UIScreen mainScreen].bounds previewImageRequired:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(show)
                                                 name:kPrimeTimeReadyToStart
                                               object:nil];
    
    // self.interactor = [[Interactor alloc] init];
    
    //self.modalPresentationStyle = UIModalPresentationCustom;
    // destinationViewController.interactor = interactor
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
    
    if (self.product.trailerPosterPreview)
    {
        NSData *posterData = [[NSData alloc] initWithBase64EncodedString:self.product.trailerPosterPreview options:0];
        UIImage *posterImage = [UIImage imageWithData:posterData];
        UIImageView *posterImageView = [[UIImageView alloc] initWithImage:posterImage];
        posterImageView.frame = self.view.bounds;
        [self.playerView addSubview:posterImageView];
    }
    
    self.playerLayer.frame = self.view.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.playerView.layer addSublayer:self.playerLayer];
    
    [self.playerTimer setHasUnlocked:__hasUnlockedVideo];
    [self.actionsView setProduct:self.product animate:YES];
    
    self.categoryLabel.text = [self.product.categoryName uppercaseString];
    self.categoryImage.image = [UIImage imageNamed:[[self.product.categoryName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString]];
    
    self.categoryImage.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    self.categoryImage.layer.shadowOffset = CGSizeMake(0, 2);
    self.categoryImage.layer.shadowOpacity = 1;
    self.categoryImage.layer.shadowRadius = 1.0;
    self.categoryImage.clipsToBounds = NO;
    
#if DEBUG
    NSString *target = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    if ([target containsString:@"Test"]) {
        [self.logoView setImage:[UIImage imageNamed:@"logo_small_test"] forState:UIControlStateNormal];
    }
#endif
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
    [_waveView startAnimating];
    
    self.categoryLabel.alpha = 0.0;
    self.categoryImage.alpha = 0.0;
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
    
    if (self.product.isAd) {
        self.contentView.hidden = YES;
    } else {
        if (!__hasDetails) {
            self.moreView.hidden = YES;
            self.arrow.hidden = YES;
        }
        
        [self setupGestureRecognizers];
    }
    
    if (self.product.hasOffer) {
        self.moreView.text = NSLocalizedString(@"CTA_OFFER", nil);
        self.arrow.image = [UIImage imageNamed:@"fire"];
        self.arrowLeadingMoreTrailing.constant = 2.0;
        self.arrowVerticalCenter.constant = -3.0;
        [self.arrow setNeedsLayout];
    }
    
    if (__hasUnlockedVideo) {
        [self.playerProgressLine setBackgroundColor:[[UIColor li5_redColor] colorWithAlphaComponent:0.6]];
    }
    
    [self setupEmbedMode];
}

- (void)setupEmbedMode {
#ifdef EMBED
    self.logoView.hidden = TRUE;
    self.playerTimer.hidden = TRUE;
    self.muteButton.hidden = TRUE;
#else
    self.categoryImage.hidden = TRUE;
    self.muteButton.hidden = TRUE;
    self.shareButton.hidden = TRUE;
#endif
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"%p",self);
    [super viewDidDisappear:animated];
    
    __hasAppeared = NO;
    
    [self removeObservers];
    
    [self.teaserPlayer pauseAndDestroy];
    
    [self updateSecondsWatched];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DDLogVerbose(@"%p",self);
    [super viewWillDisappear:animated];
    
    __hasAppeared = NO;
    
    //TODO: Fix real cause - #245 
//    if (CMTimeGetSeconds(CMTimeSubtract(self.teaserPlayer.currentItem.duration, self.teaserPlayer.currentItem.currentTime)) < 1) {
//        [self.teaserPlayer pauseAndDestroy];
//    } else {
//        [self.teaserPlayer pause];
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogVerbose(@"%p",self);
    [super viewWillAppear:animated];
    
    [self.actionsView refreshStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"%p",self);
    [super viewDidAppear:animated];
    
    __hasAppeared = YES;
    
    [self show];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //Category Animations presets
    __startPositionX = (self.view.bounds.size.width / 2.0) - (self.categoryLabel.bounds.size.width / 2.0);
    __endPositionX = self.categoryImage.layer.position.x; //endPositionX
    __space = (__endPositionX - __startPositionX);
    
    if (!__actionsViewAppeared) {
        [self toggleActionsView:NO animated:NO];
    }
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
    [[CrashlyticsLogger sharedInstance] logError:error userInfo:self.teaserPlayer];
    
    if (!__hasRetriedFailedItem) {
        [self removeObservers];
        [self.teaserPlayer pauseAndDestroy];
        
        NSURL *playerUrl = [NSURL URLWithString:self.product.trailerURL];
        _teaserPlayer = [[BCPlayer alloc] initWithUrl:playerUrl bufferInSeconds:10.0 priority:BCPriorityBuffer delegate:self];
        [self.playerLayer setPlayer:_teaserPlayer];
        
        [self.teaserPlayer play];
        [self setupObservers];
    } else {
        [TSMessage showNotificationWithTitle:NSLocalizedString(@"Error",nil)
                                    subtitle:NSLocalizedString(@"Failed to load video, please try again later.",nil)
                                        type:TSMessageNotificationTypeError];
    }

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kPrimeTimeFailedToLoad object:nil];

    __hasRetriedFailedItem = YES;
}

- (void)bufferReady
{
    DDLogVerbose(@"");
    [_waveView stopAnimating];
    
    [self.teaserPlayer play];
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
    [_waveView startAnimating];

    [self.teaserPlayer pause];
#if DEBUG
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Network slow",nil)
                                subtitle:NSLocalizedString(@"Buffer is empty, waiting for resources to finish downloading",nil)
                                    type:TSMessageNotificationTypeWarning];
#endif
    
}

- (void)networkFail:(NSError *)error
{
    DDLogError(@"");
    [[CrashlyticsLogger sharedInstance] logError:error userInfo:self.teaserPlayer];
    
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Error",nil)
                                subtitle:NSLocalizedString(@"Network failed, please try again later.",nil)
                                    type:TSMessageNotificationTypeError];
    
}

#pragma mark - Displayable Protocol

- (void)setPriority:(BCPriority)priority
{
    [self.teaserPlayer changePriority:priority];
}

- (void)show
{
    if(__hasAppeared) {
        [self.teaserPlayer changePriority:BCPriorityPlay];
    }
    if (self.teaserPlayer.status == AVPlayerStatusReadyToPlay)
    {
        [_waveView stopAnimating];
        
        [self.playerTimer setPlayer:self.teaserPlayer];
        [self.playerProgressLine setPlayer:self.teaserPlayer];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if(__hasAppeared && [userDefaults boolForKey:kLi5SwipeLeftExplainerViewPresented])
        {
            DDLogVerbose(@"%p",self);
            [self.teaserPlayer play];
            
            [self renderAnimations];
            [self setupObservers];
        }
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
    if (teaserActionsViewTimer) {
        [teaserActionsViewTimer invalidate];
        teaserActionsViewTimer = nil;
    }
    if (self.playerTimer || self.playerProgressLine) {
        [self.playerTimer setPlayer:nil];
        [self.playerProgressLine setPlayer:nil];
    }
}

- (void)setupObservers
{
    DDLogVerbose(@"");
    if (!playEndObserver)
    {
        __weak typeof(id) welf = self;
        playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.teaserPlayer.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf replayMovie:note];
            
#ifndef EMBED
            if (__hasAppeared && __hasUnlockedVideo)
            {
                if (!_modalView) {
                    _modalView = [self.storyboard instantiateViewControllerWithIdentifier:@"TapAndHoldToUnlockView"];
                    _modalView.gestureDelegate = self;
                }
                
                [self.view addSubview:_modalView.view];
            }
#endif
        }];
    }
    
    if (!teaserActionsViewTimer) {
        teaserActionsViewTimer = [NSTimer scheduledTimerWithTimeInterval:3.5
                                                                  target:self
                                                                selector:@selector(doShowActionsView:)
                                                                userInfo:nil
                                                                 repeats:NO];
    }
}

- (void)doShowActionsView:(NSTimer *)timer {
    [self toggleActionsView:YES animated:YES];
}

- (void)updateSecondsWatched
{
    int secondsWatched = (int) (CMTimeGetSeconds(self.teaserPlayer.currentTime)*1000);
    DDLogVerbose(@"%@:%i", self.product.id, secondsWatched);
    
    [FBSDKAppEvents logEvent:FBSDKAppEventNameViewedContent parameters:@{
                                                                         FBSDKAppEventParameterNameContentType: @"video",
                                                                         FBSDKAppEventParameterNameContentID: self.product.id
                                                                         }];
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 postUserWatchedVideoWithID:self.product.id withType:Li5VideoTypeTrailer during:[NSNumber numberWithFloat:secondsWatched] inContext:(self.pContext == kProductContextDiscover? Li5ContextDiscover:Li5ContextSearch) withCompletion:^(NSError *error) {
        if (error)
        {
            DDLogError(@"%@", error.localizedDescription);
            [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
        }
    }];
    
    NSDictionary *params = @{@"product":self.product.id,@"seconds":@(secondsWatched)};
    [Heap track:@"Teaser Viewed" withProperties:params];
    [Intercom logEventWithName:@"Product Viewed" metaData:params];
}

#pragma mark - User Actions

- (IBAction)muteAction:(id)sender {
    BOOL currentState = self.muteButton.isSelected;
    
    self.teaserPlayer.muted = !currentState;
    
    [self.muteButton setSelected:!currentState];
}

- (IBAction)shareAction:(id)sender {
}


- (IBAction)userDidTap:(UITapGestureRecognizer*)sender
{
    DDLogVerbose(@"");
#ifndef EMBED
    if (self.teaserPlayer.status == AVPlayerStatusReadyToPlay && __hasUnlockedVideo)
    {
        if (!_modalView) {
            _modalView = [self.storyboard instantiateViewControllerWithIdentifier:@"TapAndHoldToUnlockView"];
            _modalView.gestureDelegate = self;
        }
        
        [self.view addSubview:_modalView.view];
    }
#endif
}

- (void)handleLongTap:(UITapGestureRecognizer *)sender
{
    if (self.teaserPlayer.status == AVPlayerStatusReadyToPlay) {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            //if a VC is presented, dismiss it
            if (self.presentedViewController != nil)
            {
                [self dismissViewControllerAnimated:NO completion:^{
                    [self handleDismiss];
                }];
            }
            
            [self.parentViewController performSelectorOnMainThread:@selector(handleLongTap:) withObject:sender waitUntilDone:NO];
        }
    }
}

- (void)handleDismiss {
    [_modalView.view removeFromSuperview];
}

- (void)goBackToSearch:(UIPanGestureRecognizer *)recognizer
{
    //TODO use Search interactor
    
    ExploreProductInteractor *interactor = ((PrimeTimeViewController*)self.parentViewController.parentViewController.parentViewController).interactor;
    
    if(interactor) {
        [interactor userDidPan: recognizer];
    }
    else {
        CATransition *outTransition = [CATransition animation];
        outTransition.duration = 1.0;
        outTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        outTransition.type = kCATransitionFade;
        [self.navigationController.view.layer addAnimation:outTransition forKey:kCATransition];
        
        // [self.parentViewController.navigationController pushViewController:vc animated:NO];
        
        [self.navigationController popViewControllerAnimated:NO];
    }
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
    
    if (self.pContext == kProductContextDiscover)
    {
        //User Profile Gesture Recognizer - Swipe Down from 0-100px
        profileInteractor = [[UserProfileDynamicInteractor alloc] initWithParentViewController:self];
        searchInteractor = [[ExploreDynamicInteractor alloc] initWithParentViewController:self];

        //Profile Gesture Recognizer - Swipe Down from 0-100px
        profilePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:profileInteractor action:@selector(userDidPan:)];
        [profilePanGestureRecognizer setDelegate:self];
        [self.view addGestureRecognizer:profilePanGestureRecognizer];
#if FULL_VERSION
        //Search Products Gesture Recognizer - Swipe Down from below 100px
        searchPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:searchInteractor action:@selector(userDidPan:)];
        [searchPanGestureRecognizer setDelegate:self];
        [self.view addGestureRecognizer:searchPanGestureRecognizer];
#endif
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

- (void)toggleActionsView:(BOOL)on animated:(BOOL)animated {
    //int hideOrShow = CGRectContainsPoint(self.view.frame, self.actionsView.center)?100:-100;
    int hideOrShow = on?0:100;
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            //self.actionsView.center = CGPointApplyAffineTransform(self.actionsView.center, CGAffineTransformMakeTranslation(hideOrShow, 0));
            self.actionsView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, hideOrShow, 0);
        } completion:^(BOOL finished) {
            __actionsViewAppeared = finished && on;
        }];
    } else {
//        self.actionsView.center = CGPointApplyAffineTransform(self.actionsView.center, CGAffineTransformMakeTranslation(hideOrShow, 0));
        self.actionsView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, hideOrShow, 0);
    }
}

- (void)removeAnimations
{
    self.categoryImage.alpha = 0.0;
    self.categoryLabel.alpha = 0.0;
}

- (void)renderAnimations
{
    DDLogVerbose(@"");
    [self removeAnimations];
    
    [self __renderCategory];
    
    [self __renderMore];
    
    [self.actionsView animate];
}

- (void)__renderCategory
{
    double totalDuration = 1.2;
    double relativeDuration = 0.1 / totalDuration;
    
    CGPoint currentPosition = self.categoryImage.layer.position;
    currentPosition.x = __startPositionX;
    self.categoryImage.layer.position = currentPosition;
    
    CGRect startFrame = self.categoryLabel.frame;
    CGRect endFrame = startFrame;
    startFrame.size.width = 0;
    self.categoryLabel.frame = startFrame;
    
    //Category Image animation
    [UIView animateKeyframesWithDuration:totalDuration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        //0-0.1
        [UIView addKeyframeWithRelativeStartTime:0*relativeDuration relativeDuration:relativeDuration animations:^{
            
            self.categoryImage.alpha = 1.0;
            
            self.categoryImage.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI*.185), 0.2, 0.2);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:1*relativeDuration relativeDuration:relativeDuration animations:^{
            
            self.categoryImage.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI*.125), 0.2, 0.2);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:2*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 1.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI*.125), 0.4, 0.4);
            
        }];
        [UIView addKeyframeWithRelativeStartTime:3*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 2.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI*.125), 0.6, 0.6);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:4*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 3.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI*.125), 0.8, 0.8);
            
        }];
        
        [UIView addKeyframeWithRelativeStartTime:5*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 4.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI*.125), 1.0, 1.0);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:6*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 5.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformMakeRotation(M_PI*0.0);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:7*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 6.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformMakeRotation(-M_PI*.185);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:8*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 7.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformMakeRotation(M_PI*.0);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:9*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 8.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformMakeRotation(M_PI*.075);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:10*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 9.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformMakeRotation(M_PI*.185);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:11*relativeDuration relativeDuration:relativeDuration animations:^{
            
            CGPoint currentPosition = self.categoryImage.layer.position;
            currentPosition.x = __startPositionX+(__space * 10.0 / 10.0);
            self.categoryImage.layer.position = currentPosition;
            
            self.categoryImage.transform = CGAffineTransformMakeRotation(M_PI*.105);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
            self.categoryLabel.alpha = 1.0;
            self.categoryLabel.frame = endFrame;
        }];
        
    }completion:^(BOOL finished) {
        
    }];
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

-(BCPlayer *)getPlayer{

    return self.teaserPlayer;
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.playerLayer.frame = self.view.bounds;
    self.playerView.frame = self.view.bounds;
}

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObservers];
    [_teaserPlayer pauseAndDestroy];
}

@end
