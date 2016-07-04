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
    NSInteger __nbColumns;
    NSInteger __nbLines;
}

@end

@implementation HorizontalUICollectionViewFlowLayout

- (instancetype)initWithColumns:(NSInteger)col andRows:(NSInteger)rows
{
    DDLogVerbose(@"");
    self = [super init];
    if (self)
    {
        __nbColumns = col;
        __nbLines = rows;
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    DDLogVerbose(@"");
    [self initialize];
}

- (void)initialize
{
    DDLogVerbose(@"");
    __nbColumns = __nbColumns ?: 3;
    __nbLines = __nbLines ?: 3;
    
    [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //DDLogVerbose(@"");
    NSInteger idxPage = (int)indexPath.row / (__nbColumns * __nbLines);

    NSInteger O = indexPath.row - (idxPage * __nbColumns * __nbLines);

    NSInteger xD = (int)(O / __nbColumns);
    NSInteger yD = O % __nbColumns;

    NSInteger D = xD + yD * __nbLines + idxPage * __nbColumns * __nbLines;

    NSIndexPath *fakeIndexPath = [NSIndexPath indexPathForItem:D inSection:indexPath.section];
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:fakeIndexPath];

    // return them to collection view
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //DDLogVerbose(@"");
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
    //DDLogVerbose(@"");
    return YES;
}

- (CGSize)collectionViewContentSize
{
    //DDLogVerbose(@"");
    CGSize size = [super collectionViewContentSize];

    CGFloat pageWidth = self.collectionView.frame.size.width;
    double totalPages = ceil(size.width / pageWidth);
    CGFloat newWidth = totalPages * pageWidth;
    CGSize newSize = CGSizeMake(newWidth, size.height);

    return newSize;
}

@end
