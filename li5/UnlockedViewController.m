//
//  UnlockedViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5Player.h"
#import "Li5PlayerUISlider.h"
#import "PrimeTimeViewController.h"
#import "UnlockedViewController.h"

@import AVFoundation;

@interface UnlockedViewController ()
{
    id mFullVideoRemainingObserver;

    UIPanGestureRecognizer *_scrollViewPanGestureRecognzier;
    UIScrollView *_scrollView;
}

@property (nonatomic, strong) AVPlayerLayer *extendedVideo;
@property (nonatomic, strong) Li5PlayerUISlider *seekSlider;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation UnlockedViewController

@synthesize product;

- (id)initWithProduct:(Product *)thisProduct
{
    self = [super init];
    if (self)
    {
        self.product = thisProduct;
        [self playerLayerForExtendedVideo];
    }
    return self;
}

#pragma mark - UI View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];

    [self.view.layer addSublayer:self.extendedVideo];

    UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lockBtn setFrame:CGRectMake(20, 20, 30, 30)];
    [lockBtn setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    [lockBtn setImage:[UIImage imageNamed:@"CloseSelected"] forState:UIControlStateHighlighted];
    [lockBtn addTarget:self action:@selector(handleLockTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lockBtn];

    UITapGestureRecognizer *simpleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePauseTap:)];
    [self.view addGestureRecognizer:simpleTapGestureRecognizer];

    _scrollViewPanGestureRecognzier = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSliderSwipe:)];
    _scrollViewPanGestureRecognzier.delegate = self;
}

- (void)renderAnimations
{
    DDLogVerbose(@"rendering animations for unlocked video");
    if (!self.seekSlider)
    {
        self.seekSlider = [[Li5PlayerUISlider alloc] initWithFrame:CGRectMake(60, 30, self.view.frame.size.width - 100, 10)];
    }
    [self.view addSubview:self.seekSlider];

    if (!self.timeLabel)
    {
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 40, 20, 40, 30)];
        [self.timeLabel setTextColor:[UIColor whiteColor]];
    }
    [self.view addSubview:self.timeLabel];

    UIButton *loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loveBtn setImage:[UIImage imageNamed:@"Love"] forState:UIControlStateNormal];
    [loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateHighlighted];
    [loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateSelected];
    [loveBtn setFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 180, 30, 30)];
    [loveBtn addTarget:self action:@selector(loveProduct:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loveBtn];

    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
    [shareBtn setImage:[UIImage imageNamed:@"ShareSelected"] forState:UIControlStateHighlighted];
    [shareBtn setFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 130, 30, 30)];
    [shareBtn addTarget:self action:@selector(shareProduct:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
}

#pragma mark - Player

- (AVPlayerLayer *)playerLayerForExtendedVideo
{
    if (self.extendedVideo == nil)
    {
        NSURL *videoUrl = [NSURL URLWithString:self.product.videoURL];
        DDLogVerbose(@"Creating Full Video Player Layer for: %@", [videoUrl lastPathComponent]);
        Li5Player *player = [[Li5Player alloc] initWithItemAtURL:videoUrl];
        player.delegate = self;

        self.extendedVideo = [AVPlayerLayer playerLayerWithPlayer:player];
        //[self.extendedVideo addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
        self.extendedVideo.frame = self.view.bounds;
        self.extendedVideo.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }

    return self.extendedVideo;
}

#pragma mark - Player Delegate

- (void)li5Player:(Li5Player *)li5Player changedStatusForPlayerItem:(AVPlayerItem *)playerItem withStatus:(AVPlayerItemStatus)status
{
    if (status == AVPlayerStatusReadyToPlay)
    {
        DDLogVerbose(@"Ready to play for: %@ at %@", self.product.title, [(AVURLAsset *)li5Player.currentItem.asset URL]);

        if (!mFullVideoRemainingObserver)
        {
            __weak typeof(self) weakSelf = self;
            mFullVideoRemainingObserver = [self.extendedVideo.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                                                                  queue:NULL /* If you pass NULL, the main queue is used. */
                                                                                             usingBlock:^(CMTime time) {
                                                                                               [weakSelf updatedTimerWithSecondsRemaining:CMTimeGetSeconds(time)];
                                                                                             }];
        }

        [self renderAnimations];
        [self.seekSlider setPlayer:self.extendedVideo.player];
        [self show];
    }
}

- (void)li5Player:(Li5Player *)li5Player updatedLoadedSecondsForPlayerItem:(AVPlayerItem *)playerItem withSeconds:(CGFloat)seconds
{
    //DDLogVerbose(@"%@ at %@ ---> Loaded %f seconds of %f", [[(AVURLAsset *)playerItem.asset URL] lastPathComponent], [(AVURLAsset *)playerItem.asset URL], seconds, CMTimeGetSeconds(playerItem.duration));
}

#pragma mark - User Actions

- (void)handleLockTap:(UIButton *)sender
{
    [self.parentViewController performSelectorOnMainThread:@selector(handleLockTap:) withObject:sender waitUntilDone:NO];
}

- (void)handlePauseTap:(UIGestureRecognizer *)sender
{
    DDLogVerbose(@"Playing/Pausing player");
    CGPoint locationInView = [sender locationInView:self.view];
    if (locationInView.y >= 100)
    {
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            if (self.extendedVideo.player.rate > 0 && self.extendedVideo.player.error == nil)
            {
                [self.extendedVideo.player pause];
            }
            else
            {
                [self.extendedVideo.player play];
            }
        }
    }
}

- (void)handleSliderSwipe:(UIGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self.seekSlider sliderGestureRecognized:sender];
    }
}

- (void)shareProduct:(UIButton *)button
{
    DDLogVerbose(@"Share Button Pressed");
    NSString *textToShare = @"Look at this awesome product!";
    NSURL *productURL = [NSURL URLWithString:[[[[Li5ApiHandler sharedInstance] baseURL] stringByAppendingPathComponent:@"p"] stringByAppendingPathComponent:self.product.id]];

    NSArray *objectsToShare = @[ textToShare, productURL ];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

    NSArray *excludeActivities = @[ UIActivityTypePostToWeibo,
                                    UIActivityTypePrint,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToTencentWeibo,
                                    UIActivityTypeAirDrop ];

    activityVC.excludedActivityTypes = excludeActivities;

    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)loveProduct:(UIButton *)button
{
    DDLogVerbose(@"Love Button Pressed");
    if (button.selected)
    {
        [button setSelected:false];
        [[Li5ApiHandler sharedInstance] deleteLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
          if (error != nil)
          {
              [button setSelected:true];
          }
        }];
    }
    else
    {
        [button setSelected:true];
        [[Li5ApiHandler sharedInstance] postLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
          if (error != nil)
          {
              [button setSelected:false];
          }
        }];
    }
}

#pragma mark - Displayable Protocol

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    float secondsWatched = CMTimeGetSeconds(self.extendedVideo.player.currentTime);
    DDLogVerbose(@"User saw %@ during %f", self.product.id, secondsWatched);
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 postUserWatchedVideoWithID:self.product.id withType:Li5VideoTypeFull during:[NSNumber numberWithFloat:secondsWatched] inContext:Li5ContextDiscover withCompletion:^(NSError *error) {
      if (error)
      {
          DDLogError(@"%@", error.localizedDescription);
      }
    }];

    [_scrollView removeGestureRecognizer:_scrollViewPanGestureRecognzier];

    [self.extendedVideo.player pause];
}

- (void)show
{
    if (self.extendedVideo.player.status == AVPlayerStatusReadyToPlay &&
        self.parentViewController.parentViewController != nil &&
        self.parentViewController.parentViewController == [((PrimeTimeViewController *)self.parentViewController.parentViewController.parentViewController).viewControllers firstObject])
    {
        DDLogVerbose(@"Show %@.", [[(AVURLAsset *)self.extendedVideo.player.currentItem.asset URL] lastPathComponent]);

        if (!_scrollView)
        {
            for (UIView *view in self.parentViewController.parentViewController.parentViewController.view.subviews)
            {
                if ([view isKindOfClass:[UIScrollView class]])
                {
                    _scrollView = (UIScrollView *)view;
                    _scrollView.delaysContentTouches = false;
                }
            }
        }

        [_scrollView addGestureRecognizer:_scrollViewPanGestureRecognzier];

        [self.extendedVideo.player play];
    }
}

- (void)redisplay
{
    [self.extendedVideo.player seekToTime:kCMTimeZero];
    //[self.extendedVideo.player play]; //called already by seektotime
}

#pragma mark - Gesture Recognizers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _scrollViewPanGestureRecognzier)
    {
        CGPoint locationInView = [gestureRecognizer locationInView:self.view];
        if (locationInView.y < 100)
        {
            return YES;
        }
        return NO;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL result = NO;
    if ((otherGestureRecognizer == _scrollViewPanGestureRecognzier) && [[gestureRecognizer view] isKindOfClass:[UIScrollView class]])
    {
        result = YES;
    }
    return result;
}

//gestureRecognizer:shouldRequireFailureOfGestureRecognizer:
//gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:

#pragma mark - Observer Actions

- (void)updatedTimerWithSecondsRemaining:(CGFloat)seconds
{
    float remainingSeconds = CMTimeGetSeconds(self.extendedVideo.player.currentItem.duration) - seconds;
    self.timeLabel.text = (remainingSeconds >= 0 ? [NSString stringWithFormat:@"%.0f", remainingSeconds] : @"");
}

#pragma mark - Device Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (mFullVideoRemainingObserver)
    {
        //DDLogVerbose(@"removing %@ from player %@",timeObserver,[self currentPlayer]);
        [self.extendedVideo.player removeTimeObserver:mFullVideoRemainingObserver];
        mFullVideoRemainingObserver = nil;
    }
    if (self.extendedVideo != nil)
    {
        //[self.extendedVideo removeObserver:self forKeyPath:@"readyForDisplay"];
        self.extendedVideo = nil;
    }
}

@end
