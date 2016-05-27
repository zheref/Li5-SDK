//
//  UserProductsCollectionViewDataSource.h
//  li5
//
//  Created by Martin Cocaro on 5/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "PrimeTimeViewControllerDataSource.h"

@interface UserProductsCollectionViewDataSource : PrimeTimeViewControllerDataSource <UICollectionViewDataSource>

- (void)getUserLovesWithCompletion:(void (^)(NSError *error))completion;

- (void)fetchMoreUserLovesWithCompletion:(void (^)(NSError *error))completion;

@end
