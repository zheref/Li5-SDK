//
//  CategoriesCollectionViewCell.h
//  li5
//
//  Created by Leandro Fournier on 4/15/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import Li5Api;
@import BCVideoPlayer;
@import AVFoundation;

@interface CategoriesCollectionViewCell : UICollectionViewCell <BCPlayerDelegate>

@property (weak, nonatomic) Category *category;

@end
