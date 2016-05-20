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

@property (nonatomic, strong) NSArray<Product *> *loves;

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

- (void)getUserLovesWithCompletion:(void (^)(NSError *error))completion {
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    __weak typeof(self) welf = self;
    [li5 requestUserLovesWithCompletion:^(NSError *error, NSArray<Product *> *products) {
        DDLogVerbose(@"total loves: %lu", (unsigned long)products.count);
        welf.loves = [NSArray arrayWithArray:products];
        completion (error);
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _loves.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lovesCollectionCell" forIndexPath:indexPath];
    Product *product = [_loves objectAtIndex:indexPath.row];
    
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:product.videoPreview]
                      placeholderImage:nil
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 //DDLogVerbose(@"completed");
                             }];
    
    return cell;
}

#pragma mark - ProductPageViewControllerDataSource

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index {
    if ((index >= [self numberOfProducts]) || (index == NSNotFound))
    {
        return nil;
    }
    
    return [[ProductPageViewController alloc] initWithProduct:[_loves objectAtIndex:index] andIndex:index forContext:kProductContextSearch];
}

- (UIViewController *)pageViewController:(UIPageViewController *)thisPageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return [super pageViewController:thisPageViewController viewControllerBeforeViewController:viewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)thisPageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return [super pageViewController:thisPageViewController viewControllerAfterViewController:viewController];
}

- (NSUInteger)numberOfProducts {
    return [_loves count];
}

@end
