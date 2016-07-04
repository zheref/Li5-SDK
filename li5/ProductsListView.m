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
#import "ProductsCollectionViewCell.h"

static const CGFloat lineSpacing = 6.0;
static const CGFloat interimItemSpacing = 5.0;

static const CGFloat topSectionInset = 5.0;
static const CGFloat bottomSectionInset = 6.0;
static const CGFloat leftSectionInset = 5.0;
static const CGFloat rightSectionInset = 5.0;

@interface ProductsListView ()

@property (nonatomic, assign) BOOL fetching;

@end

@implementation ProductsListView

#pragma mark - UI Setup

- (void)initialize
{
    DDLogVerbose(@"");
    [super initialize];

    _fetching = NO;
}

- (void)awakeFromNib
{
    DDLogVerbose(@"");
    [super awakeFromNib];
    
    [_collectionView setCollectionViewLayout:[[HorizontalUICollectionViewFlowLayout alloc] initWithColumns:self.columns andRows:self.rows]];
    [_collectionView registerNib:[UINib nibWithNibName:@"ProductsCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"productListCell"];
    [_collectionView setDelegate:self];
}

- (void)prepareForInterfaceBuilder
{
    DDLogVerbose(@"");
//    [_collectionView setDataSource:[ProductsListViewIBDataSource new]];
//    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"");
    CGFloat width = (collectionView.frame.size.width - leftSectionInset - rightSectionInset - (self.columns-1)*lineSpacing) / self.columns;
    CGFloat height = (collectionView.frame.size.height - topSectionInset - bottomSectionInset - (self.rows-1)*interimItemSpacing ) / self.rows;
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    DDLogVerbose(@"");
    return lineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    DDLogVerbose(@"");
    return interimItemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    DDLogVerbose(@"");
    return UIEdgeInsetsMake(topSectionInset, leftSectionInset, bottomSectionInset, rightSectionInset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"");
    if (self.delegate)
    {
        [self.delegate didSelectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"");
    [((ProductsCollectionViewCell *)cell) didEndDisplayingCell];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DDLogVerbose(@"");
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
