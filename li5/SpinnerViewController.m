//
//  SpinnerViewController.m
//  li5
//
//  Created by Martin Cocaro on 6/14/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import AVFoundation;

#import "SpinnerViewController.h"
#import "Li5Constants.h"

@interface SpinnerViewController ()
{
    AVPlayerLayer *loadingLayer;
    id playEndObserver;
}

@property (weak, nonatomic) IBOutlet UIView *spinnerView;

@end

@implementation SpinnerViewController

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
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
            [notificationCenter addObserver:self
                                   selector:@selector(hideMovie)
                                       name:kPrimeTimeFailedToLoad
                                     object:nil];
}

#pragma mark - UI Setup

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    DDLogVerbose(@"");
    [super viewDidLoad];
    
    NSString *loadingPath = [[NSBundle mainBundle] pathForResource:@"logo_loading" ofType:@"mp4"];
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:loadingPath]];
    loadingLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    loadingLayer.frame = self.view.bounds;
    loadingLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.spinnerView.layer addSublayer:loadingLayer];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    [loadingLayer.player play];
    
    [self setupVideoEndObservers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
    
    [self hideMovie];
}

- (void)replayMovie:(NSNotification *)notification
{
    DDLogVerbose(@"replaying animation");
    [loadingLayer.player seekToTime:kCMTimeZero];
    [loadingLayer.player play];
}

- (void)hideMovie
{
    DDLogVerbose(@"");
    [loadingLayer.player pause];
    
    [self removeVideoEndObservers];
    
    _spinnerView.hidden = TRUE;
}

#pragma mark - Observers

- (void)setupVideoEndObservers
{
    if (!playEndObserver)
    {
        __weak typeof(id) welf = self;
        playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:loadingLayer.player.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf replayMovie:note];
        }];
    }
}

- (void)removeVideoEndObservers
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:loadingLayer.player.currentItem];
    playEndObserver = nil;
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [loadingLayer.player replaceCurrentItemWithPlayerItem:nil];
    loadingLayer = nil;
    
    [self removeVideoEndObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
