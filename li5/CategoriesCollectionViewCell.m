//
//  CategoriesCollectionViewCell.m
//  li5
//
//  Created by Leandro Fournier on 4/15/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import AVFoundation;

#import "CategoriesCollectionViewCell.h"

@interface CategoriesCollectionViewCell ()
{
    id __playerEndObserver;
}

@property (strong, nonatomic) BCPlayer *previewVideo;

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

#pragma mark - Public Methods

- (void)setCategory:(Category *)category
{
    _category = category;

    self.titleLbl.text = [[_category name] uppercaseString];

    _previewVideo = [[BCPlayer alloc] initWithUrl:[NSURL URLWithString:[category image]] bufferInSeconds:10.0 priority:BCPriorityPlay delegate:self];
    _previewVideo.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _previewVideo.muted = TRUE;

    AVPlayerLayer *previewVideoLayer = [AVPlayerLayer playerLayerWithPlayer:_previewVideo];
    previewVideoLayer.frame = self.bounds;
    previewVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.categoryVideoView.layer addSublayer:previewVideoLayer];
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
