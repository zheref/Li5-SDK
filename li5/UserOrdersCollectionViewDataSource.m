//
//  UserOrdersCollectionViewDataSource.m
//  li5
//
//  Created by Martin Cocaro on 6/6/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "ProductsCollectionViewCell.h"
#import "UserOrdersCollectionViewDataSource.h"
#import "ProductPageViewController.h"

@interface UserOrdersCollectionViewDataSource ()

@property (nonatomic, strong) NSMutableArray<Order *> *orders;
@property (nonatomic, strong) Cursor *cursor;

@end

@implementation UserOrdersCollectionViewDataSource

#pragma mark - Init Methods

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _orders = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Methods

- (void)startFetchingProductsInBackgroundWithCompletion:(void (^)(NSError *))completion
{
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    __weak typeof(self) welf = self;
    [li5 requestUserOrdersWithCompletion:^(NSError *error, NSArray<Order *> *orders) {
        DDLogVerbose(@"total orders: %lu", (unsigned long)orders.count);
        welf.orders = [NSMutableArray arrayWithArray:orders];
        welf.cursor = nil;
        if (completion)
        {
            completion (error);
        }
    } andCursor:nil];
}

- (void)fetchMoreProductsWithCompletion:(void (^)(NSError *error))completion
{
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    __weak typeof(self) welf = self;
    [li5 requestUserOrdersWithCompletion:^(NSError *error, NSArray<Order *> *orders) {
        DDLogVerbose(@"more orders: %lu", (unsigned long)orders.count);
        [welf.orders arrayByAddingObjectsFromArray:orders];
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
    return self.orders.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"productListCell" forIndexPath:indexPath];
    Order *order = [self.orders objectAtIndex:indexPath.row];
    
    [cell setOrder:order];
    
    return cell;
}

#pragma mark - ProductPageViewControllerDataSource

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index {
    if ((index >= [self numberOfProducts]) || (index == NSNotFound))
    {
        return nil;
    }
    
    return [[ProductPageViewController alloc] initWithOrder:[self.orders objectAtIndex:index] forContext:kProductContextSearch];
}

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index withPriority:(BCPriority)priority
{
    ProductPageViewController *controller = [self productPageViewControllerAtIndex:index];
    [controller setPriority:priority];
    return controller;
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
    return [self.orders count];
}

@end
