//
//  RootViewControllerDataSource.h
//  li5
//
//  Created by Leandro Fournier on 3/29/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductPageViewController.h"
#import "Li5UIPageViewController.h"

@interface PrimeTimeViewControllerDataSource : NSObject <Li5UIPageViewControllerDataSource>

- (void)startFetchingProductsInBackgroundWithCompletion:(void (^)(NSError *error))completion;
- (void)fetchMoreProductsWithCompletion:(void (^)(NSError *error))completion;
- (NSUInteger)numberOfProducts;
- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index;

- (BOOL)isExpired;

@end
