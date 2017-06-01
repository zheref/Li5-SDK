//
//  ProductsCollectionViewCell.m
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "ProductsCollectionViewCell.h"
#import "ImageHelper.h"

@interface ProductsCollectionViewCell ()

@property (weak, nonatomic) IBOutlet Li5GradientView *orderDetails;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property (weak, nonatomic) IBOutlet UILabel *orderStatus;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (strong, nonatomic) ImageHelper *imageHelper;

@end

@implementation ProductsCollectionViewCell

#pragma mark - UI Setup

- (void)awakeFromNib {
    DDLogVerbose(@"");
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse
{
    DDLogVerbose(@"");
    [super prepareForReuse];
    [self cleanup];
}

- (void)updateViews
{
    DDLogVerbose(@"Thumb: %@ - Preview: %@",self.product.trailerThumbnail,self.product.videoPreview);
    // Initialize the progress view
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.orderDetails.hidden = (self.order == nil);
        self.orderStatus.text = self.order.status;
        
        NSURL *url = [NSURL URLWithString:self.product.videoPreview];
        
        __weak ProductsCollectionViewCell *welf = self;
        
        self.imageHelper = [[ImageHelper alloc] init];
        
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            [self.imageHelper getImage:url completationHandler:^(NSData * _Nullable data) {
                if(data != nil) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
                        YYImage *image = [YYImage imageWithData:data];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            welf.imageView = [[YYAnimatedImageView alloc] initWithImage:image];
                            //                    welf.imageView.runloopMode = NSDefaultRunLoopMode;
                            welf.imageView.layer.cornerRadius = 6;
                            welf.imageView.frame = welf.bounds;
                            
                            [welf.videoView addSubview:welf.imageView];
                        });
                    });
                }
            }];
        }];
        
        NSString *price = [NSString stringWithFormat:@"$%.00f",(self.order != nil ?[self.order.total doubleValue]:[self.product.price doubleValue]) / 100];
        
        self.productTitle.text = self.product.title;
        self.productPrice.text = price;
    });
}

- (void)willDisplayCell
{
    DDLogVerbose(@"");
    [self updateViews];
}

- (void)didEndDisplayingCell
{
    DDLogVerbose(@"");
    [self cleanup];
}

- (void)cleanup
{
    DDLogVerbose(@"");
    [self.imageHelper cancel];
    self.imageHelper = nil;
    
    [[_videoView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.imageView stopAnimating];
    self.imageView = nil;
}

#pragma mark - Public Methods

- (void)setProduct:(Product *)product
{
    DDLogVerbose(@"");
    _product = product;
    _order = nil;
}

- (void)setOrder:(Order*)order
{
    DDLogVerbose(@"");
    _order = order;
    _product = order.product;
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [self cleanup];
    self.imageView = nil;
    self.imageHelper = nil;
}

@end
