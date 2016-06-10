//
//  ProductsCollectionViewCell.m
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductsCollectionViewCell.h"

@interface ProductsCollectionViewCell ()
{
    id __playerEndObserver;
}

@property (weak, nonatomic) IBOutlet Li5GradientView *orderDetails;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property (weak, nonatomic) IBOutlet UILabel *orderStatus;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (strong, nonatomic) BCPlayer *previewVideoPlayer;

@end

@implementation ProductsCollectionViewCell

#pragma mark - UI Setup

- (void)awakeFromNib {
    DDLogVerbose(@"");
    [super awakeFromNib];
    // Initialization code
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)prepareForReuse
{
    DDLogVerbose(@"");
    [super prepareForReuse];
    [self removeObservers];
    _previewVideoPlayer = nil;
}

- (void)updateViews
{
    DDLogVerbose(@"");
    self.orderDetails.hidden = (self.order == nil);
    
    self.orderStatus.text = self.order.status;
    
    DDLogVerbose(@"%@",self.product.videoPreview);
    
    NSURL *videoPreviewURL = [NSURL URLWithString:self.product.videoPreview];
    _previewVideoPlayer = [[BCPlayer alloc] initWithUrl:videoPreviewURL bufferInSeconds:10.0 priority:BCPriorityHigh delegate:self];
    _previewVideoPlayer.muted = YES;
    _previewVideoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    AVPlayerLayer *previewVideoLayer = [AVPlayerLayer playerLayerWithPlayer:_previewVideoPlayer];
    previewVideoLayer.frame = self.bounds;
    previewVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.videoView.layer addSublayer:previewVideoLayer];

    NSString *price = [NSString stringWithFormat:@"$%.00f",[self.product.price doubleValue] / 100];
    
    self.productTitle.text = self.product.title;
    self.productPrice.text = price;
}

- (void)didEndDisplayingCell
{
    DDLogVerbose(@"");
//    [self.previewVideoPlayer play];
}

#pragma mark - BCPlayerDelegate

- (void)readyToPlay
{
    DDLogVerbose(@"");
    [self setupObservers];
    [self.previewVideoPlayer play];
}

- (void)failToLoadItem
{
    DDLogVerbose(@"");
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
}

#pragma mark - Observers

- (void)setupObservers
{
    DDLogVerbose(@"");
    if (!__playerEndObserver)
    {
        __weak typeof(self) welf = self;
        __playerEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.previewVideoPlayer.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf.previewVideoPlayer seekToTime:kCMTimeZero];
            [welf.previewVideoPlayer play];
        }];
    }
}

- (void)removeObservers
{
    DDLogVerbose(@"");
    if (__playerEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:__playerEndObserver];
        __playerEndObserver = nil;
    }
}

#pragma mark - Public Methods

- (void)setProduct:(Product *)product
{
    DDLogVerbose(@"");
    _product = product;
    _order = nil;
    
    [self updateViews];
}

- (void)setOrder:(Order*)order
{
    DDLogVerbose(@"");
    _order = order;
    _product = order.product;
    
    [self updateViews];
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"");
    [self removeObservers];
}

@end
