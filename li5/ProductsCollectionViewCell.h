//
//  ProductsCollectionViewCell.h
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import SDWebImage;
@import Li5Api;
@import BCVideoPlayer;
@import AVFoundation;

#import "Li5GradientView.h"

//IB_DESIGNABLE
@interface ProductsCollectionViewCell : UICollectionViewCell <BCPlayerDelegate>

@property (weak, nonatomic) Product *product;
@property (weak, nonatomic) Order *order;

- (void)didEndDisplayingCell;

@end
