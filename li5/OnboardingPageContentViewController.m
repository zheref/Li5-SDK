//
//  OnboardingPageContentViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/30/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import AVFoundation;

#import "OnboardingPageContentViewController.h"
#import "UIView+Li5.h"
#import "UIViewController+Indexed.h"

@interface OnboardingPageContentViewController ()
{
    id playEndObserver;
}

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *videoLayer;
@property (nonatomic, assign) BOOL viewAppeared;

@end

@implementation OnboardingPageContentViewController

#pragma mark - UI Setup

- (void)viewDidLoad {
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.videoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.titleLabel.text = self.titleText;
    self.subtitleLabel.text = self.subtitleText;
    
    if (self.videoUrl != nil)
    {
//        _player = [[BCPlayer alloc] initWithUrl:self.videoUrl bufferInSeconds:20.0 priority:BCPriorityHigh delegate:self];
//        _videoLayer = [[BCPlayerLayer alloc] initWithPlayer:_player andFrame:self.view.bounds];
        _player = [AVPlayer playerWithURL:self.videoUrl];
        _videoLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        
        _videoLayer.frame = self.view.bounds;
        _videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        [self.videoView.layer addSublayer:_videoLayer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewWillAppear:animated];
    
    _viewAppeared = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    [self __setupAnimations];
    
    [self readyToPlay];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewWillDisappear:animated];
    
    _viewAppeared = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
    
    [self.player pause];
    [self removeObservers];
}

- (void)__setupAnimations
{
//    NSUInteger index = self.scrollPageIndex;
//    if (index == 0 )
//    {
//        //    [[self.titleLabel.superview constraintForIdentifier:@"titleBottomConstraint"] setActive:NO];
//        //    [[self.subtitleLabel.superview constraintForIdentifier:@"subtitleTopConstraint"] setActive:NO];
//        //    [self.view setNeedsUpdateConstraints];
//        //    [self.view layoutIfNeeded];
//        
//        ////Title animation
//        CAKeyframeAnimation * titleOpacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
//        titleOpacityAnim.values                = @[@0, @1];
//        titleOpacityAnim.keyTimes              = @[@0, @1];
//        titleOpacityAnim.duration              = 1;
//        titleOpacityAnim.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//        
//        //    CAKeyframeAnimation * titlePositionAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//        //    titlePositionAnim.values    = @[[NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(0, -50)], [NSValue valueWithCGAffineTransform:CGAffineTransformIdentity]];
//        //    titlePositionAnim.keyTimes  = @[@0, @1];
//        //    titlePositionAnim.duration  = 0.603;
//        //    titlePositionAnim.beginTime = 0.442;
//        
//        CAAnimationGroup * titleLogoAnimationsAnim = [CAAnimationGroup animation];
//        titleLogoAnimationsAnim.animations = @[titleOpacityAnim];
//        titleLogoAnimationsAnim.fillMode = kCAFillModeForwards;
//        [self.titleLabel.layer addAnimation:titleLogoAnimationsAnim forKey:@"TitleLogoAnimationsAnim"];
//        
//        //    [UIView animateKeyframesWithDuration:0.6 delay:0.442 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
//        //
//        //        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:<#(double)#> animations:<#^(void)animations#>]
//        //
//        //    } completion:^(BOOL finished) {
//        //
//        //    }];
//        
//        //    [self.titleLabel.superview constraintForIdentifier:@"titleBottomConstraint"].constant = 150.0;
//        //    [UIView animateWithDuration:1.0 delay:0.442 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        //        [self.view layoutIfNeeded];
//        //    } completion:nil];
//        
//        //    ////Subtitle animation
//        //    CAKeyframeAnimation * subtitlePositionAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//        //    subtitlePositionAnim.values    = @[[NSValue valueWithCGPoint:CGPointMake(181.75, 532)], [NSValue valueWithCGPoint:CGPointMake(181.75, 575)]];
//        //    subtitlePositionAnim.keyTimes  = @[@0, @1];
//        //    subtitlePositionAnim.duration  = 0.603;
//        //    subtitlePositionAnim.beginTime = 0.442;
//        //
//        //    CAKeyframeAnimation * subtitleOpacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
//        //    subtitleOpacityAnim.values   = @[@0, @1];
//        //    subtitleOpacityAnim.keyTimes = @[@0, @1];
//        //    subtitleOpacityAnim.duration = 1;
//        //    
//        //    CAAnimationGroup * subtitleLogoAnimationsAnim = [CAAnimationGroup animation];
//        //    subtitleLogoAnimationsAnim.animations = @[subtitlePositionAnim, subtitleOpacityAnim];
//        //    [self.subtitleLabel.layer addAnimation:subtitleLogoAnimationsAnim forKey:@"SubtitleLogoAnimationsAnim"];
//    }
}

- (void)readyToPlay
{
    if (/*self.player.status == AVPlayerStatusReadyToPlay &&*/ self.viewAppeared)
    {
        [self.player play];
        [self setupObservers];
    }
}

- (void)failToLoadItem:(NSError *)error
{
    
}

- (void)bufferEmpty
{
    
}

- (void)networkFail:(NSError *)error
{
    DDLogError(@"");
}

- (void)replay
{
    DDLogVerbose(@"");
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
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
        playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf replay];
        }];
    }
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
