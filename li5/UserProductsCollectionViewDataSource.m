//
//  UserProductsCollectionViewDataSource.m
//  li5
//
//  Created by Martin Cocaro on 5/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "UserProductsCollectionViewDataSource.h"
#import "ProductsCollectionViewCell.h"

@interface UserProductsCollectionViewDataSource ()

@property (nonatomic, strong) NSMutableArray<Product *> *loves;

@property (nonatomic, strong) Cursor *cursor;

@end

@implementation UserProductsCollectionViewDataSource

#pragma mark - Init Methods

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _loves = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Methods

- (void)startFetchingProductsInBackgroundWithCompletion:(void (^)(NSError *))completion
{
    if ([self numberOfProducts] <= 0)
    {
        Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
        __weak typeof(self) welf = self;
        [li5 requestUserLovesWithCompletion:^(NSError *error, NSArray<Product *> *products) {
            DDLogVerbose(@"total loves: %lu", (unsigned long)products.count);
            welf.loves = [NSMutableArray arrayWithArray:products];
            //TODO loves with cursor data
            welf.cursor = nil;
            if (completion)
            {
                completion (error);
            }
        } andCursor:nil];
    }
}

- (void)fetchMoreProductsWithCompletion:(void (^)(NSError *error))completion
{
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    __weak typeof(self) welf = self;
    [li5 requestUserLovesWithCompletion:^(NSError *error, NSArray<Product *> *products) {
        DDLogVerbose(@"total loves: %lu", (unsigned long)products.count);
        [welf.loves arrayByAddingObjectsFromArray:products];
        if (completion)
        {
            completion (error);
        }
    } andCursor:self.cursor];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _loves.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"productListCell" forIndexPath:indexPath];
    Product *product = [_loves objectAtIndex:indexPath.row];
    
    [cell setProduct:product];
    return cell;
}

#pragma mark - ProductPageViewControllerDataSource

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index {
    if ((index >= [self numberOfProducts]) || (index == NSNotFound))
    {
        return nil;
    }
    
    return [[ProductPageViewController alloc] initWithProduct:[_loves objectAtIndex:index] forContext:kProductContextSearch];
}

- (UIViewController *)viewControllerBeforeViewController:(UIViewController *)viewController
{
    return [super viewControllerBeforeViewController:viewController];
}

- (UIViewController *)viewControllerAfterViewController:(UIViewController *)viewController
{
    return [super viewControllerAfterViewController:viewController];
}

- (NSUInteger)numberOfProducts {
    return [_loves count];
}

@end
