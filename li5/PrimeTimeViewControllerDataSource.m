//
//  RootViewControllerDataSource.m
//  li5
//
//  Created by Leandro Fournier on 3/29/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "LastPageViewController.h"
#import "PrimeTimeViewControllerDataSource.h"

@interface PrimeTimeViewControllerDataSource ()

@property (nonatomic, strong) NSMutableArray<Product *> *products;

@end

@implementation PrimeTimeViewControllerDataSource

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)startFetchingProductsInBackgroundWithCompletion:(void (^)(NSError *error))completion
{
    self.products = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
      //Background Thread
      Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
      [li5 requestDiscoverProductsWithCompletion:^(NSError *error, NSArray<Product *> *products) {
        DDLogVerbose(@"Total products: %lu", (unsigned long)products.count);
        if (error == nil)
        {
            if (products.count > 0)
            {
                self.products = [NSMutableArray arrayWithArray:products];
            }
        }
        else
        {
            DDLogVerbose(@"Error retrieving products: %@ %@", error, [error userInfo]);
        }

        completion(error);
      }];
    });
}

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index
{
    if ((index >= [self numberOfProducts]) || (index == NSNotFound))
    {
        LastPageViewController *lastVC = [[LastPageViewController alloc] initWithNibName:@"LastPageViewController" bundle:[NSBundle mainBundle]];
        [lastVC setIndex:index];
        return lastVC;
    }
    return [[ProductPageViewController alloc] initWithProduct:[self.products objectAtIndex:index] andIndex:index forContext:kProductContextDiscover];
}

- (NSUInteger)numberOfProducts
{
    return [self.products count];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)thisPageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ProductPageViewController *)viewController).index;

    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    else
    {
        return [self productPageViewControllerAtIndex:index - 1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)thisPageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[ProductPageViewController class]])
    {
        NSUInteger index = ((ProductPageViewController *)viewController).index;
        if ((index >= [self numberOfProducts]) || (index == NSNotFound))
        {
            return nil;
        }
        else
        {
            return [self productPageViewControllerAtIndex:index + 1];
        }
    }
    else
    {
        return nil;
    }
}

@end
