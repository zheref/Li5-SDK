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
    
    NSString *_originalMessage;
}

@property (weak, nonatomic) IBOutlet UIView *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButton;
@property (weak, nonatomic) IBOutlet UIImageView *backView;

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
                           selector:@selector(displayErrorAndHideMovie:)
                               name:kPrimeTimeFailedToLoad
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(viewDidAppear:)
                               name:UIApplicationDidBecomeActiveNotification
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
    
#ifndef EMBED
    _originalMessage = self.message.text;
    NSString *loadingPath = [[NSBundle mainBundle] pathForResource:@"logo_loading" ofType:@"mp4"];
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:loadingPath]];
    loadingLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    loadingLayer.frame = self.view.bounds;
    loadingLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.spinnerView.layer addSublayer:loadingLayer];
#else
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
    _originalMessage = prodName;
    [self.backView setImage:nil];
    [self.backView setBackgroundColor:[UIColor li5_blackish]];
    self.message.text = prodName;
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    [self fetchPrimeTime:nil];
    
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

- (void)displayErrorAndHideMovie:(NSNotification*)notification {
    DDLogVerbose(@"");
    
    [self hideMovie];
    
    self.message.text = ((NSError*)[notification object]).localizedDescription;
    self.tryAgainButton.hidden = NO;
}

- (IBAction)fetchPrimeTime:(id)sender {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kFetchPrimeTime object:nil];
    
    _spinnerView.hidden = NO;
    self.tryAgainButton.hidden = YES;
    
    self.message.text = _originalMessage;
    
    [self replayMovie:nil];
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

- (void)removeObservers {
    [self removeVideoEndObservers];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [loadingLayer.player replaceCurrentItemWithPlayerItem:nil];
    loadingLayer = nil;
    
    [self removeObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
