//
//  ProductsCollectionViewCell.m
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import MMMaterialDesignSpinner;

#import "ProductsCollectionViewCell.h"
#import "ImageHelper.h"

@interface ProductsCollectionViewCell ()

@property (weak, nonatomic) IBOutlet Li5GradientView *orderDetails;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property (weak, nonatomic) IBOutlet UILabel *orderStatus;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (strong, nonatomic) YYAnimatedImageView *imageView;
@property (strong, nonatomic) ImageHelper *imageHelper;

@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;

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
    [self.imageHelper cancel];
    
    [[_videoView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [self.imageView stopAnimating];
    self.imageView = nil;
}

- (void)updateViews
{
    DDLogVerbose(@"Thumb: %@ - Preview: %@",self.product.trailerThumbnail,self.product.videoPreview);
    // Initialize the progress view
    
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(self.frame.size.width/2,self.frame.size.height/2,15.0,15.0)];
    self.spinnerView.lineWidth = 1.5f;
    self.spinnerView.tintColor = [UIColor lightGrayColor];
    self.spinnerView.hidesWhenStopped = YES;
    [self.videoView addSubview:self.spinnerView];
    
    [self.spinnerView startAnimating];
    
    self.orderDetails.hidden = (self.order == nil);
    self.orderStatus.text = self.order.status;
    
    NSURL *url = [NSURL URLWithString:self.product.videoPreview];
    
    __weak ProductsCollectionViewCell *welf = self;
    
    self.imageHelper = [[ImageHelper alloc] init];
    
    [self.imageHelper getImage:url completationHandler:^(NSData * _Nullable data) {
        if(data != nil) {
            
            YYImage *image = [YYImage imageWithData:data];
            welf.imageView = [[YYAnimatedImageView alloc] initWithImage:image];
            welf.imageView.layer.cornerRadius = 6;
            [welf.videoView addSubview:welf.imageView];
        }
        [self.spinnerView stopAnimating];
    }];
    
    NSString *price = [NSString stringWithFormat:@"$%.00f",[self.product.price doubleValue] / 100];
    
    self.productTitle.text = self.product.title;
    self.productPrice.text = price;
}

- (void)didEndDisplayingCell
{
    DDLogVerbose(@"");
    //    [self.previewVideoPlayer play];
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
    DDLogDebug(@"%p",self);
    self.imageView = nil;
    self.imageHelper = nil;
    self.spinnerView = nil;
}

@end