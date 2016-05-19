//
//  UserProductsCollectionViewDataSource.h
//  li5
//
//  Created by Martin Cocaro on 5/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProductsCollectionViewDataSource : NSObject <UICollectionViewDataSource>

- (void)getUserLovesWithCompletion:(void (^)(NSError *error))completion;

@end
