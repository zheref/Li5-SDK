//
//  ProductsListView.h
//  li5
//
//  Created by Martin Cocaro on 5/21/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5View.h"

@protocol ProductsListViewDelegate;

IB_DESIGNABLE
@interface ProductsListView : Li5View <UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) IBInspectable NSInteger columns;
@property (nonatomic, assign) IBInspectable NSInteger rows;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) id<ProductsListViewDelegate> delegate;

@end

@protocol ProductsListViewDelegate <NSObject>

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)fetchMoreProductsWithCompletion:(void (^)(void))completion;

@end