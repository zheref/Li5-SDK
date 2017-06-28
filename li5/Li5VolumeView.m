//
//  Li5VolumeView.m
//  li5
//
//  Created by Martin Cocaro on 6/16/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import UIKit;
@import MediaPlayer;
@import AVFoundation;

#import "Li5VolumeView.h"

/**
 Replace the system volume popup with a more subtle way to display the volume
 when the user changes it with the volume rocker.
 */
@interface Li5VolumeView ()

@property (nonatomic, strong) MPVolumeView *volume;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, assign) CGFloat volumeLevel;

@end

@implementation Li5VolumeView

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

- (void)initialize
{
    _volumeLevel = 0.0;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    _overlay = [UIView new];
    _overlay.backgroundColor = [UIColor whiteColor];
    [self addSubview:_overlay];
    
    @try {
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [self updateVolumeWith:[audioSession outputVolume] animated:false];
        [audioSession addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:nil];

        _volume = [[MPVolumeView alloc] initWithFrame:CGRectZero];
        [_volume setVolumeThumbImage:[UIImage new] forState:UIControlStateNormal];
        _volume.userInteractionEnabled = false;
        _volume.alpha = 0.0001;
        _volume.showsRouteButton = false;
        [self addSubview:_volume];
        
    } @catch (NSException *exception) {
        DDLogError(@"unable to initialize AVAudioSession %@", exception.description);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.overlay.frame = CGRectMake(0,0, self.frame.size.width * self.volumeLevel, self.frame.size.height);
}

- (void)updateVolumeWith:(CGFloat)value animated:(BOOL)animated
{
    self.volumeLevel = value;
    
    [UIView animateWithDuration:(animated ? 0.1 : 0) animations:^{
        self.overlay.transform = CGAffineTransformMakeTranslation(self.volumeLevel, 0.0);
    }];
    
    [UIView animateKeyframesWithDuration:(animated ? 2.0 : 0.0) delay:0.0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.0 animations:^{
            self.alpha = 1;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            self.alpha = 0.0001;
        }];
        
    } completion:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"outputVolume"])
    {
        CGFloat value = [[change valueForKey:@"new"] floatValue];
        
        DDLogVerbose(@"changing volume to: %f",value);
        
        [self updateVolumeWith:value animated:true];
    }
}

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
}

@end
