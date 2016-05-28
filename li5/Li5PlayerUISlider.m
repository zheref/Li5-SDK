//
//  Li5PlayerUISlider.m
//  li5
//
//  Created by Martin Cocaro on 4/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5PlayerUISlider.h"
#import "UIColor+Li5UIColor.h"

@interface Li5PlayerUISlider ()
{
    float __mRestoreAfterScrubbingRate;
    id __mTimeObserver;
    id __mTimeRemainingObserver;
}

//Slider Variables
@property (nonatomic, strong) CALayer *progressView;
@property (nonatomic, assign) CGFloat currentProgress;
@property (nonatomic, strong) UILabel *timeLabel;

//Slider Gesture Recognizers
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation Li5PlayerUISlider

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [[UIColor li5_charcoalColor] colorWithAlphaComponent:0.25];

    //Progress View
    _progressView = [CALayer layer];
    _progressView.backgroundColor = [UIColor li5_yellowColor].CGColor;
    _progressView.anchorPoint = CGPointZero;
    _progressView.position = CGPointZero;
    [self.layer addSublayer:self.progressView];

    _timeLabel = [UILabel new];
    [_timeLabel setTextColor:[UIColor whiteColor]];
    [_timeLabel setFont:[UIFont fontWithName:@"Rubik-Bold" size:16.0]];
    [_timeLabel setShadowColor:[UIColor li5_charcoalColor]];
    [_timeLabel setShadowOffset:CGSizeMake(0, 2)];
    [self addSubview:_timeLabel];

    _currentProgress = 0.0;

    [self setupGestureRecognizers];
}

#pragma mark - UI Setup

- (void)layoutSubviews
{
    [super layoutSubviews];

    //Adjust height size to fill entire view
    CGRect progressRect = self.progressView.bounds;
    progressRect.size.height = CGRectGetHeight(self.frame);
    self.progressView.bounds = progressRect;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return TRUE;
}

- (void)updateConstraints
{
    [super updateConstraints];

    [self.timeLabel makeConstraints:^(MASConstraintMaker *make) {
      make.centerY.equalTo(self);
      make.trailing.equalTo(self).with.offset(-20);
    }];
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers
{
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];

    _tapGestureRecognizer.cancelsTouchesInView = NO;
    _panGestureRecognizer.cancelsTouchesInView = NO;

    self.gestureRecognizers = @[ _tapGestureRecognizer, _panGestureRecognizer ];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return (gestureRecognizer == _tapGestureRecognizer || gestureRecognizer == _panGestureRecognizer);
}

- (void)userDidTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self beginScrubbing:self];
        [self sliderValueChanged:sender];
        [self scrub:self];
        [self endScrubbing:self];
    }
}

- (void)userDidPan:(UIPanGestureRecognizer *)sender
{
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:

            [self beginScrubbing:self];

            break;
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:

            [self sliderValueChanged:sender];
            [self scrub:self];

            break;
        case UIGestureRecognizerStateEnded:

            [self endScrubbing:self];

            break;
        default:
            break;
    }
}

- (void)sliderValueChanged:(UIGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:sender.view];
    CGFloat totalWidth = CGRectGetWidth(self.frame);
    CGFloat percentage = touchPoint.x / totalWidth;

    [self setProgress:percentage animated:NO];
}

#pragma mark - Public Methods

- (CGFloat)setProgress:(CGFloat)percentage animated:(BOOL)animated
{
    CGRect currentProgressRect = self.progressView.frame;
    CGRect endProgressRect = self.frame;
    endProgressRect.size.width = percentage * endProgressRect.size.width;

    if (animated)
    {
        CABasicAnimation *extendToRight = [CABasicAnimation animationWithKeyPath:@"bounds"];
        extendToRight.fromValue = [NSValue valueWithCGRect:currentProgressRect];
        extendToRight.toValue = [NSValue valueWithCGRect:endProgressRect];
        extendToRight.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        extendToRight.duration = [self getTimerInterval];
        extendToRight.delegate = self;

        [self.progressView removeAllAnimations];
        [self.progressView addAnimation:extendToRight forKey:@"scroll"];
    }

    self.progressView.bounds = endProgressRect;

    _currentProgress = percentage;

    return _currentProgress;
}

- (CGFloat)getProgress
{
    return _currentProgress;
}

- (void)setPlayer:(AVPlayer *)aPlayer
{
    if (aPlayer != _player)
    {
        _player = aPlayer;

        [self setupObservers];
        [self syncScrubber];
    }
}

#pragma mark - Scrubbing

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }

    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        double time = CMTimeGetSeconds([self.player currentTime]);

        [self setProgress:(time / duration) animated:YES];
    }
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (void)beginScrubbing:(id)sender
{
    __mRestoreAfterScrubbingRate = [self.player rate];
    [self.player setRate:0.f];

    /* Remove previous timer. */
    [self removeObservers];
}

/* Set the player current time to match the scrubber position. */
- (void)scrub:(id)sender
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }

    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        __block double time = duration * _currentProgress;

        [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished){
            [self updatedTimerWithSecondsRemaining:time];
        }];
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (void)endScrubbing:(id)sender
{
    [self setupObservers];

    if (__mRestoreAfterScrubbingRate)
    {
        [self.player setRate:__mRestoreAfterScrubbingRate];
        __mRestoreAfterScrubbingRate = 0.f;
    }
}

- (BOOL)isScrubbing
{
    return __mRestoreAfterScrubbingRate != 0.f;
}

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return ([playerItem duration]);
    }

    return (kCMTimeInvalid);
}

- (double)getTimerInterval
{
    double interval = .5f;

    CMTime playerDuration = [self playerItemDuration];
    if (!CMTIME_IS_INVALID(playerDuration))
    {
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([self bounds]);
            interval = 0.5f * duration / width;
        }
    }

    return interval;
}

#pragma mark - Observers

- (void)setupObservers
{
    if (!__mTimeRemainingObserver)
    {
        __weak typeof(self) weakSelf = self;
        __mTimeRemainingObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                                             queue:NULL /* If you pass NULL, the main queue is used. */
                                                                        usingBlock:^(CMTime time) {
                                                                          [weakSelf updatedTimerWithSecondsRemaining:CMTimeGetSeconds(time)];
                                                                        }];
    }

    if (!__mTimeObserver)
    {
        double interval = [self getTimerInterval];

        __weak typeof(id) weakSelf = self;
        __mTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:
                                                                                                                                       ^(CMTime time) {
                                                                                                                                         [weakSelf syncScrubber];
                                                                                                                                       }];
    }
}

- (void)removeObservers
{
    if (__mTimeRemainingObserver)
    {
        [self.player removeTimeObserver:__mTimeRemainingObserver];
        [__mTimeRemainingObserver invalidate];
        __mTimeRemainingObserver = nil;
    }

    if (__mTimeObserver)
    {
        [self.player removeTimeObserver:__mTimeObserver];
        [__mTimeObserver invalidate];
        __mTimeObserver = nil;
    }
}

- (void)updatedTimerWithSecondsRemaining:(CGFloat)seconds
{
    float remainingSeconds = CMTimeGetSeconds(self.player.currentItem.duration) - seconds;
    self.timeLabel.text = (remainingSeconds >= 0 ? [NSString stringWithFormat:@"%.0f", remainingSeconds] : @"");
}

#pragma mark - Animations Handling

- (void)pauseAnimation
{
    //    CFTimeInterval pausedTime = [self.progressView convertTime:CACurrentMediaTime() fromLayer:nil];
    //    self.progressView.speed = 0.0;
    //    self.progressView.timeOffset = pausedTime;
}

- (void)resumeAnimation
{
    //    CFTimeInterval pausedTime = [self.progressView timeOffset];
    //    self.progressView.speed = 1.0;
    //    self.progressView.timeOffset = 0.0;
    //    self.progressView.beginTime = 0.0;
    //    CFTimeInterval timeSincePause = [self.progressView convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    //    self.progressView.beginTime = timeSincePause;
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"no longer needed");
    [self removeObservers];
}

@end
