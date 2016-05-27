//
//  ProductsListView.m
//  li5
//
//  Created by Martin Cocaro on 5/21/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "HorizontalUICollectionViewFlowLayout.h"
#import "ProductsListView.h"
#import "UserProductsCollectionViewDataSource.h"

static const CGFloat lineSpacing = 4.0;

static const CGFloat interimItemSpacing = 4.0;

@interface ProductsListView ()

@property (nonatomic, assign) BOOL fetching;

@end

@implementation ProductsListView

#pragma mark - UI Setup

- (void)initialize
{
    [super initialize];

    _fetching = NO;
    [_collectionView setCollectionViewLayout:[[HorizontalUICollectionViewFlowLayout alloc] initWithColumns:_columns andRows:_rows]];
    [_collectionView registerNib:[UINib nibWithNibName:@"ProductsCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"productListCell"];
    [_collectionView setDelegate:self];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = collectionView.frame.size.width / self.columns -interimItemSpacing;
    CGFloat height = collectionView.frame.size.height / self.rows -lineSpacing;
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return lineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return interimItemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate)
    {
        [self.delegate didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    
    NSInteger totalPages = (int) scrollView.contentSize.width / scrollView.frame.size.width;
    
    if (page >= totalPages -1 )
    {
        if (self.delegate && !_fetching)
        {
            self.fetching = YES;
            __weak typeof(self) welf = self;
            [self.delegate fetchMoreProductsWithCompletion:^{
                welf.fetching = NO;
            }];
        }
    }
}

@end
