//
//  ProductsCollectionViewCell.h
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import SDWebImage;
@import Li5Api;
@import AVFoundation;
@import YYImage;
#import "Li5GradientView.h"

//IB_DESIGNABLE
@interface ProductsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) Product *product;
@property (weak, nonatomic) Order *order;
@property (strong, nonatomic) YYAnimatedImageView *imageView;

- (void)willDisplayCell;
- (void)didEndDisplayingCell;

@end
