//
//  Li5PlayerUISlider.m
//  li5
//
//  Created by Martin Cocaro on 4/25/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "Li5PlayerUISlider.h"
#import "SliderFluidView.h"

@interface Li5PlayerUISlider ()
{
    float __mRestoreAfterScrubbingRate;
    id __mTimeObserver;
    id __mTimeRemainingObserver;
    CGFloat __timeInterval;
}

//Slider Variables
//@property (nonatomic, strong) CALayer *progressView;
@property (nonatomic, strong) SliderFluidView *progressView;
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
    self.clipsToBounds = YES;
    
    //Progress View
//    _progressView = [CALayer layer];
//    _progressView.backgroundColor = [UIColor li5_yellowColor].CGColor;
//    _progressView.anchorPoint = CGPointZero;
//    _progressView.position = CGPointZero;
//    [self.layer addSublayer:self.progressView];
    _progressView = [[SliderFluidView alloc] initWithFrame:self.bounds];
    [self addSubview:_progressView];
//    _progressView = [[BAFluidView alloc] initWithFrame:self.bounds];
//    _progressView.fillAutoReverse = NO;
//    _progressView.fillRepeatCount = 1;
//    _progressView.maxAmplitude = 50;
//    _progressView.minAmplitude = 20;
//    _progressView.strokeColor = [UIColor li5_yellowColor];
//    _progressView.fillColor = [UIColor li5_yellowColor];
//    // We rotate the frame to make the animation horizontally
//    _progressView.transform = CGAffineTransformMakeRotation(M_PI_2);
//    _progressView.frame = self.bounds;
//    [self addSubview:_progressView];

    _timeLabel = [UILabel new];
    [_timeLabel setTextColor:[UIColor whiteColor]];
    [_timeLabel setFont:[UIFont fontWithName:@"Rubik-Bold" size:16.0]];
    [_timeLabel setShadowColor:[UIColor li5_charcoalColor]];
    [_timeLabel setShadowOffset:CGSizeMake(0, 2)];
    [self addSubview:_timeLabel];

    _currentProgress = 0.0;
    __timeInterval = .5f;

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

- (void)prepareForInterfaceBuilder
{
    [self setProgress:0.5f animated:NO];
    self.timeLabel.text = @"15";
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
    if (percentage <0) percentage = 0;
    if (percentage > 1) percentage = 1;
    
//    CGRect currentProgressRect = self.progressView.frame;
//    CGRect endProgressRect = self.frame;
//    endProgressRect.size.width = percentage * endProgressRect.size.width;
//
//    self.progressView.bounds = endProgressRect;
    [self.progressView.fluidView fillTo:@(percentage)];
    _currentProgress = percentage;
    
//    if (animated)
//    {
//        CABasicAnimation *extendToRight = [CABasicAnimation animationWithKeyPath:@"bounds"];
//        extendToRight.fromValue = [NSValue valueWithCGRect:currentProgressRect];
//        extendToRight.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        extendToRight.duration = __timeInterval;
//        extendToRight.delegate = self;
//        extendToRight.removedOnCompletion = NO;
//        extendToRight.fillMode = kCAFillModeForwards;
//        extendToRight.autoreverses = NO;
//
//        [self.progressView removeAllAnimations];
//        [self.progressView addAnimation:extendToRight forKey:@"scroll"];
//    }

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

        CMTime playerDuration = [self playerItemDuration];
        if (!CMTIME_IS_INVALID(playerDuration))
        {
            double duration = CMTimeGetSeconds(playerDuration);
            if (isfinite(duration))
            {
                CGFloat width = CGRectGetWidth([self bounds]);
                __timeInterval = 0.5f * duration / width;
            }
        }
        
        [self setupObservers];
    }
}

#pragma mark - Scrubbing

/* Set the scrubber based on the player current time. */
- (void)syncScrubberWithTime:(CMTime)timePlayed
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }

    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        double time = CMTimeGetSeconds(timePlayed);
        
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
        double time = duration * _currentProgress;
        
        [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished){
            if (finished) [self updatedTimerWithSecondsRemaining:time];
        }];
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (void)endScrubbing:(id)sender
{
    [self setupObservers];

//    if (__mRestoreAfterScrubbingRate)
//    {
//        [self.player setRate:__mRestoreAfterScrubbingRate];
//        __mRestoreAfterScrubbingRate = 0.f;
//    }
    [self.player setRate:1.0];
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

#pragma mark - Observers

- (void)setupObservers
{
    if (!__mTimeRemainingObserver)
    {
        __weak typeof(self) weakSelf = self;
        __mTimeRemainingObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                                             queue:NULL
                                                                        usingBlock:^(CMTime time) {
                                                                          [weakSelf updatedTimerWithSecondsRemaining:CMTimeGetSeconds(time)];
                                                                        }];
    }

    if (!__mTimeObserver)
    {
        double interval = __timeInterval;
        
        __weak typeof(id) weakSelf = self;
        __mTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                    queue:NULL usingBlock:^(CMTime time) {
                                                                        [weakSelf syncScrubberWithTime:time];
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
    [self removeObservers];
}

@end
