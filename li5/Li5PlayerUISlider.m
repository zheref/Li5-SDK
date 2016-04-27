//
//  Li5PlayerUISlider.m
//  li5
//
//  Created by Martin Cocaro on 4/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5PlayerUISlider.h"

@interface Li5PlayerUISlider ()
{
    
    float mRestoreAfterScrubbingRate;
    id mTimeObserver;
    BOOL isSeeking;
}

@property (nonatomic,weak) AVPlayer *player;

@end

@implementation Li5PlayerUISlider

#pragma mark - Initialization
#pragma mark -

-  (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    
    if (self) {
        [self initializeTapSlider];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeTapSlider];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andPlayer:(AVPlayer*) aPlayer
{
    self = [self initWithFrame:frame];
    if (self) {
        self.player = aPlayer;
        
        [self initializeTapSlider];
    }
    return self;
}

- (instancetype)initWithPlayer:(AVPlayer*) aPlayer
{
    self = [self init];
    if (self) {
        self.player = aPlayer;
        
        [self initializeTapSlider];
    }
    return self;
}

- (void)setPlayer:(AVPlayer *)aPlayer
{
    DDLogVerbose(@"");
    if( aPlayer != _player )
    {
        _player = aPlayer;
        
        [self initScrubberTimer];
        [self syncScrubber];
    }
}

/*
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    DDLogVerbose(@"");
    return bounds;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds
                   trackRect:(CGRect)rect
                       value:(float)value
{
    DDLogVerbose(@"");
    return bounds;
}
 */

#pragma mark - Private
#pragma mark -

- (void)initializeTapSlider
{
    DDLogVerbose(@"");
    
    self.thumbTintColor = [UIColor redColor];
    self.continuous = NO;
    
    [self modifySlider:self];
    isSeeking = NO;
}

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
    DDLogVerbose(@"");
    if (!mTimeObserver) {
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
        
        /* Update the scrubber during normal playback. */
        __weak typeof(id) weakSelf = self;
        mTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                  queue:NULL // If you pass NULL, the main queue is used.
                                                             usingBlock:^(CMTime time)
                         {
                             [weakSelf syncScrubber];
                         }];
    }
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
    //DDLogVerbose(@"");
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [self minimumValue];
        float maxValue = [self maximumValue];
        double time = CMTimeGetSeconds([self.player currentTime]);
        
        [self setValue:(maxValue - minValue) * time / duration + minValue animated:YES];
    }
}

- (void)modifySlider:(UISlider *)slider
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderGestureRecognized:)];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderGestureRecognized:)];
    
    slider.gestureRecognizers = @[tapGestureRecognizer, panGestureRecognizer];
}

#pragma mark - User Actions
#pragma mark -

- (void)sliderValueChanged:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat percentage = point.x / width;
    
    // new value is based on the slider's min and max values which
    // could be different with each slider
    float newValue = ((self.maximumValue - self.minimumValue) * percentage) + self.minimumValue;
    [self setValue:newValue animated:TRUE];
}

- (void)sliderGestureRecognized:(id)sender
{
    [self handleSliderGestureRecognizer:(UIGestureRecognizer *)sender];
}

- (void)tapSliderGestureRecognized:(id)sender
{
    [self beginScrubbing:self];
    [self sliderValueChanged:(UIGestureRecognizer *)sender];
    [self scrub:self];
    [self endScrubbing:self];
}

- (void)handleSliderGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    switch ([recognizer state])
    {
        case UIGestureRecognizerStateBegan:
            [self beginScrubbing:self];
            break;
        case UIGestureRecognizerStateChanged:
            [self sliderValueChanged:recognizer];
            [self scrub:self];
            break;
        default:
            [self endScrubbing:self];
            break;
    }
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (void)beginScrubbing:(id)sender
{
    mRestoreAfterScrubbingRate = [self.player rate];
    [self.player setRate:0.f];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
- (void)scrub:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]] && !isSeeking)
    {
        isSeeking = YES;
        UISlider* slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            
            __block double time = duration * (value - minValue) / (maxValue - minValue);
            
            [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    DDLogVerbose(@"seeking to time %f",time);
                    isSeeking = NO;
                });
            }];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (void)endScrubbing:(id)sender
{
    if (!mTimeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([self bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak typeof(id) weakSelf = self;
            mTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                             ^(CMTime time)
                             {
                                 [weakSelf syncScrubber];
                             }];
        }
    }
    
    if (mRestoreAfterScrubbingRate)
    {
        [self.player setRate:mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate = 0.f;
    }
}

- (BOOL)isScrubbing
{
    return mRestoreAfterScrubbingRate != 0.f;
}

-(void)enableScrubber
{
    self.enabled = YES;
}

-(void)disableScrubber
{
    self.enabled = NO;
}

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

-(void)removePlayerTimeObserver
{
    if (mTimeObserver)
    {
        //DDLogVerbose(@"removing %@ from player %@",timeObserver,[self currentPlayer]);
        [self.player removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}

#pragma mark - OS Actions

- (void)dealloc
{
    [self removePlayerTimeObserver];
}

@end
