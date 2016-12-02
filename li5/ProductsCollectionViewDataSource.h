//
//  ProductsCollectionViewDataSource.h
//  li5
//
//  Created by Leandro Fournier on 4/29/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import Li5Api;

#import "ProductPageViewController.h"
#import "PrimeTimeViewControllerDataSource.h"

@interface ProductsCollectionViewDataSource : PrimeTimeViewControllerDataSource <UICollectionViewDataSource>

- (void)getProductsWithQuery:(NSString *)query progress:(void (^)())progress withCompletion:(void (^)(NSError *error))completion;

- (void)fetchMoreProductsWithCompletion:(void (^)(NSError *error))completion;

- (NSInteger)totalProducts;

@end
