//
//  RootViewControllerDataSource.h
//  li5
//
//  Created by Leandro Fournier on 3/29/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductPageViewController.h"

@interface PrimeTimeViewControllerDataSource : NSObject <UIPageViewControllerDataSource>

- (void)startFetchingProductsInBackgroundWithCompletion:(void (^)(NSError *error))completion;
- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfProducts;

@end
