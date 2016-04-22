//
//  RootViewControllerDataSource.m
//  li5
//
//  Created by Leandro Fournier on 3/29/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "RootViewControllerDataSource.h"
#import "Li5ApiHandler.h"

@interface RootViewControllerDataSource ()

@property (nonatomic, strong) NSMutableArray <Product *> *products;
@property (nonatomic, strong) NSMutableArray <ProductPageViewController *> *productPages;

@end

@implementation RootViewControllerDataSource

- (void)startFetchingProductsInBackgroundWithCompletion:(void (^)(NSError *error))completion{
    
    self.productPages = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        //Background Thread
        Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
        [li5 requestDiscoverProductsWithCompletion:^(NSError *error, NSArray<Product *> *products) {
            DDLogVerbose(@"PRODUCTS: %@", products);
            if (error == nil) {
                self.products = [NSMutableArray arrayWithArray:products];
                [self productPageViewControllerAtIndex:0];
                completion(error);
            } else {
                DDLogVerbose(@"Error retrieving products: %@ %@", error, [error userInfo]);
                completion(error);
            }
        }];
    });
}

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index {
    BOOL createNewPageViewController = false;
    if ([self.productPages count] == 0) {
        createNewPageViewController = true;
    } else if (index > [self.productPages count]-1) {
        createNewPageViewController = true;
    }
    
    if (createNewPageViewController) {
        DDLogVerbose(@"CREATING PRODUCT PAGE FOR PRODUCT %lu", (unsigned long)index);
        [self.productPages addObject:[[ProductPageViewController alloc] initWithProduct:[self.products objectAtIndex:index] andIndex:index]];
    }
    
    DDLogVerbose(@"RETRIEVING PRODUCT PAGE FOR PRODUCT %lu", (unsigned long)index);
    return [self.productPages objectAtIndex:index];
}

- (NSUInteger)numberOfLoadedProductPages {
    return [self.productPages count];
}

- (NSUInteger)numberOfProducts {
    return [self.products count];
}

#pragma mark - UIPageViewControllerDataSource

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
    NSUInteger index = ((ProductPageViewController*) viewController).index;
    
    if ((index+1 == [self numberOfProducts]) || (index == NSNotFound))
    {
        return nil;
    } else {
        return [self productPageViewControllerAtIndex:index+1];
    }
}

@end
