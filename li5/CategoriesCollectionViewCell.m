//
//  CategoriesCollectionViewCell.m
//  li5
//
//  Created by Leandro Fournier on 4/15/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import AVFoundation;

#import "CategoriesCollectionViewCell.h"

@interface CategoriesCollectionViewCell ()
{
    id __playerEndObserver;
}

@property (strong, nonatomic) AVPlayer *previewVideo;
@property (strong, nonatomic) AVPlayerLayer *previewVideoLayer;

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIView *categoryVideoView;

@end

@implementation CategoriesCollectionViewCell

#pragma mark - UI Setup

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self removeObservers];
    self.previewVideo = nil;
    [self.previewVideoLayer removeFromSuperlayer];
}

#pragma mark - Public Methods

- (void)setCategory:(Category *)category
{
    _category = category;

    self.titleLbl.text = [[_category name] uppercaseString];

    NSURL *categoryURL = [NSURL URLWithString:[category image]];
    categoryURL = [[NSBundle mainBundle] URLForResource:[[categoryURL lastPathComponent] stringByDeletingPathExtension] withExtension:[categoryURL pathExtension]];
    _previewVideo = [[BCPlayer alloc] initWithFileUrl:categoryURL delegate:self];
//    _previewVideo = [[BCPlayer alloc] initWithUrl:categoryURL bufferInSeconds:10.0 priority:BCPriorityPlay delegate:self];

    _previewVideo.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _previewVideo.muted = TRUE;

    _previewVideoLayer = [AVPlayerLayer playerLayerWithPlayer:_previewVideo];
    _previewVideoLayer.frame = self.bounds;
    _previewVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.categoryVideoView.layer addSublayer:_previewVideoLayer];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    if (selected)
    {
        [self.titleLbl setBackgroundColor:[UIColor clearColor]];
        [self setupObservers];
        
        if(self.previewVideo.status == AVPlayerItemStatusReadyToPlay) {
            [self.previewVideo play];
        }
    }
    else
    {
        [self.titleLbl setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
        [_previewVideo seekToTime:kCMTimeZero];
        [_previewVideo pause];
        [self removeObservers];
    }
}

#pragma mark - BCPlayerDelegate

- (void)readyToPlay
{
    DDLogVerbose(@"");
    if (super.selected)
    {
        [self setupObservers];
        [_previewVideo play];
    }
}

- (void)failToLoadItem:(NSError*)error
{
    DDLogError(@"failed to load item %@",error.description);
    [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
}

- (void)bufferReady
{
    DDLogVerbose(@"");
}

- (void)networkFail:(NSError *)error
{
    DDLogError(@"");
    [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
}

#pragma mark - Observers

- (void)setupObservers
{
    if (!__playerEndObserver)
    {
        __weak typeof(self) welf = self;
        __playerEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.previewVideo.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf.previewVideo seekToTime:kCMTimeZero];
            [welf.previewVideo play];
        }];
    }
}

- (void)removeObservers
{
    if (__playerEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:__playerEndObserver];
        __playerEndObserver = nil;
    }
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [self removeObservers];
}

@end
