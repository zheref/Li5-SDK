//
//  HorizontalUICollectionViewFlowLayout.m
//  li5
//
//  Created by Martin Cocaro on 5/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "HorizontalUICollectionViewFlowLayout.h"

@interface HorizontalUICollectionViewFlowLayout ()
{
    NSInteger nbColumns;
    NSInteger nbLines;
}

@end

@implementation HorizontalUICollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize
{
    nbColumns = 3;
    nbLines = 3;
    [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger idxPage = (int)indexPath.row / (nbColumns * nbLines);

    NSInteger O = indexPath.row - (idxPage * nbColumns * nbLines);

    NSInteger xD = (int)(O / nbColumns);
    NSInteger yD = O % nbColumns;

    NSInteger D = xD + yD * nbLines + idxPage * nbColumns * nbLines;

    NSIndexPath *fakeIndexPath = [NSIndexPath indexPathForItem:D inSection:indexPath.section];
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:fakeIndexPath];

    // return them to collection view
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    CGFloat newX = MIN(0, rect.origin.x - rect.size.width / 2);
    CGFloat newWidth = rect.size.width * 2 + (rect.origin.x - newX);

    CGRect newRect = CGRectMake(newX, rect.origin.y, newWidth, rect.size.height);

    // Get all the attributes for the elements in the specified frame
    NSArray *allAttributesInRect = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:newRect] copyItems:YES];

    for (UICollectionViewLayoutAttributes *attr in allAttributesInRect)
    {
        UICollectionViewLayoutAttributes *newAttr = [self layoutAttributesForItemAtIndexPath:attr.indexPath];

        attr.frame = newAttr.frame;
        attr.center = newAttr.center;
        attr.bounds = newAttr.bounds;
        attr.hidden = newAttr.hidden;
        attr.size = newAttr.size;
    }

    return allAttributesInRect;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (CGSize)collectionViewContentSize
{
    CGSize size = [super collectionViewContentSize];

    CGFloat pageWidth = self.collectionView.frame.size.width;
    double totalPages = ceil(size.width / pageWidth);
    CGFloat newWidth = totalPages * pageWidth;
    CGSize newSize = CGSizeMake(newWidth, size.height);

    return newSize;
}

@end
