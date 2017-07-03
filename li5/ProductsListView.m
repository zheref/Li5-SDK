//
//  ProductsListView.m
//  li5
//
//  Created by Martin Cocaro on 5/21/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "HorizontalUICollectionViewFlowLayout.h"
#import "ProductsListView.h"
#import "ProductsCollectionViewCell.h"

static const CGFloat lineSpacing = 5.0;
static const CGFloat interimItemSpacing = 5.0;

static const CGFloat topSectionInset = 5.0;
static const CGFloat bottomSectionInset = 6.0;
static const CGFloat leftSectionInset = 0.0;
static const CGFloat rightSectionInset = 0.0;

@interface ProductsListView () {
    NSOperationQueue *__queue;
}

@property (nonatomic, assign) BOOL fetching;

@end

@implementation ProductsListView

#pragma mark - UI Setup

- (void)initialize
{
    [super initialize];

    _fetching = NO;
    __queue = [[NSOperationQueue alloc] init];
    __queue.name = @"Product List Queue";
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_collectionView setCollectionViewLayout:[[HorizontalUICollectionViewFlowLayout alloc] initWithColumns:self.columns andRows:self.rows]];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"ProductsCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"productListCell"];
    [_collectionView setDelegate:self];
}

- (void)prepareForInterfaceBuilder
{
//    [_collectionView setDataSource:[ProductsListViewIBDataSource new]];
//    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat width = ((collectionView.frame.size.width - leftSectionInset - rightSectionInset) / self.columns) - lineSpacing;
    CGFloat height = (collectionView.frame.size.height - topSectionInset - bottomSectionInset - (self.rows-1)*interimItemSpacing ) / self.rows;
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
    return UIEdgeInsetsMake(topSectionInset, leftSectionInset, bottomSectionInset, rightSectionInset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate)
    {
        [self.delegate didSelectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((ProductsCollectionViewCell *)cell) willDisplayCell];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((ProductsCollectionViewCell *)cell) didEndDisplayingCell];
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
            [__queue addOperationWithBlock:^{
                [welf.delegate fetchMoreProductsWithCompletion:^{
                    welf.fetching = NO;
                }];
            }];
        }
    }
}

@end
