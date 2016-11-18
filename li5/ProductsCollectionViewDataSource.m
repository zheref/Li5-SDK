//
//  ProductsCollectionViewDataSource.m
//  li5
//
//  Created by Leandro Fournier on 4/29/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import AVFoundation;

#import "ProductsCollectionViewDataSource.h"
#import "ProductsCollectionViewCell.h"

@interface ProductsCollectionViewDataSource ()

@property (nonatomic, strong) NSMutableArray<Product *> *products;

@property (nonatomic, strong) NSString *lastSearch;
@property (nonatomic, strong) Cursor *cursor;

@end

@implementation ProductsCollectionViewDataSource

- (id)init {
    if (self = [super init]) {
        _products = [NSMutableArray array];
        _lastSearch = nil;
        _cursor = nil;
    }
    return self;
}

- (void)getProductsWithQuery:(NSString *)query progress:(void (^)())progress withCompletion:(void (^)(NSError *error))completion {
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    __weak typeof(self) welf = self;
    _products = [NSMutableArray array];
    _lastSearch = nil;
    _cursor = nil;
    if (query.length > 0 && query.length < 3) {
        return;
    }
    progress();
    [li5 requestProductsWithQuery:query andCursor:nil withCompletion:^(NSError *error, NSArray<Product *> *products, Cursor *cursor) {
        if (error != nil) {
            DDLogError(@"%@",error.description);
        }
        DDLogVerbose(@"total products: %lu", (unsigned long)products.count);
        welf.products = [NSMutableArray arrayWithArray:products];
        welf.lastSearch = query;
        welf.cursor = cursor;
        completion (error);
    }];
}

- (void)fetchMoreProductsWithCompletion:(void (^)(NSError *))completion
{
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    __weak typeof(self) welf = self;
    [li5 requestProductsWithQuery:self.lastSearch andCursor:self.cursor withCompletion:^(NSError *error, NSArray<Product *> *products, Cursor *cursor) {
        if (error != nil) {
            DDLogError(@"%@",error.description);
        }
        DDLogVerbose(@"total new products: %lu", (unsigned long)products.count);
        [welf.products addObjectsFromArray:products];
        welf.cursor = cursor;
        completion (error);
    }];
}

- (NSInteger)totalProducts
{
    return self.products.count;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.products count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"productListCell" forIndexPath:indexPath];
    if (self.products.count > indexPath.row)
    {
        Product *product = [self.products objectAtIndex:indexPath.row];
        [cell setProduct:product];
        return cell;
    }
    return cell;
}

#pragma mark - UIPageViewControllerDataSource

- (void)startFetchingProductsInBackgroundWithCompletion:(void (^)(NSError *))completion
{
    completion(nil);
}

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index {
    
    if(index >= [self numberOfProducts]) {
        return nil;
    }
    
    return [[ProductPageViewController alloc] initWithProduct:[self.products objectAtIndex:index] forContext:kProductContextSearch];
}

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index withPriority:(BCPriority)priority
{
    ProductPageViewController *controller = [self productPageViewControllerAtIndex:index];
    [controller setPriority:priority];
    return controller;
}

- (UIViewController *)viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = viewController.scrollPageIndex;
    
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    } else {
        return [self productPageViewControllerAtIndex:index-1];
    }
}

- (UIViewController *)viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[ProductPageViewController class]]) {
        NSUInteger index = viewController.scrollPageIndex;
        if ((index+1 == [self numberOfProducts]) || (index == NSNotFound))
        {
            return nil;
        } else {
            return [self productPageViewControllerAtIndex:index+1];
        }
    } else {
        return nil;
    }
}

- (NSUInteger)numberOfProducts {
    return [self.products count];
}

@end
