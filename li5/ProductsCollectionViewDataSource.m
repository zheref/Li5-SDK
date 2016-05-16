//
//  ProductsCollectionViewDataSource.m
//  li5
//
//  Created by Leandro Fournier on 4/29/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductsCollectionViewDataSource.h"
#import "ProductsCollectionViewCell.h"

@interface ProductsCollectionViewDataSource ()

@property (nonatomic, strong) NSMutableArray<Product *> *allProducts;
@property (nonatomic, strong) NSMutableArray<Product *> *filteredProducts;
@property (nonatomic, strong) Cursor *actualCursor;
@property (nonatomic, strong) Cursor *searchActualCursor;
@property (nonatomic, assign) BOOL searching;

@end

@implementation ProductsCollectionViewDataSource

- (id)init {
    if (self = [super init]) {
        _allProducts = [NSMutableArray array];
        _filteredProducts = [NSMutableArray array];
    }
    return self;
}

- (void)getProductsWithQuery:(NSString *)query withCompletion:(void (^)(NSError *error))completion {
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    __weak typeof(self) welf = self;
    [li5 requestProductsWithQuery:query andCursor:(_searching ? _searchActualCursor : _actualCursor) withCompletion:^(NSError *error, NSArray<Product *> *products, Cursor *cursor) {
        DDLogVerbose(@"total products: %lu", (unsigned long)products.count);
        if (error == nil) {
            if (_searching) {
                [welf.filteredProducts addObjectsFromArray:products];
                welf.searchActualCursor = cursor;
            } else {
                [welf.allProducts addObjectsFromArray:products];
                welf.actualCursor = cursor;
            }
            completion (nil);
        } else {
            completion (error);
        }
    }];
}

- (void)isSearching {
    _searching = true;
    [self resetSearchStatus];
}

- (void)isNotSearching {
    _searching = false;
    [self resetSearchStatus];
}

- (void)resetSearchStatus {
    _searchActualCursor = nil;
    [_filteredProducts removeAllObjects];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_searching) {
        return [_filteredProducts count];
    } else {
        return [_allProducts count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    Product *product = (_searching ? [_filteredProducts objectAtIndex:indexPath.row] : [_allProducts objectAtIndex:indexPath.row] );
    
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:product.videoPreview]
                      placeholderImage:nil
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 //DDLogVerbose(@"completed");
                             }];
    
    return cell;
}

#pragma mark - UIPageViewControllerDataSource

- (void)startFetchingProductsInBackgroundWithCompletion:(void (^)(NSError *))completion
{
    completion(nil);
}

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index {
    return [[ProductPageViewController alloc] initWithProduct:[(_searching ? _filteredProducts : _allProducts) objectAtIndex:index] andIndex:index forContext:kProductContextSearch];
}

- (UIViewController *)pageViewController:(UIPageViewController *)thisPageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ProductPageViewController*) viewController).index;
    
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    } else {
        return [self productPageViewControllerAtIndex:index-1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)thisPageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[ProductPageViewController class]]) {
        NSUInteger index = ((ProductPageViewController*) viewController).index;
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
    return (_searching ? [_filteredProducts count] : [_allProducts count]);
}

@end
