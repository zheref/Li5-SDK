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

@property (nonatomic, strong) NSDate *expiresAt;
@property (nonatomic, strong) NSString *endOfPrimeTime;
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
      [li5 requestDiscoverProductsWithCompletion:^(NSError *error, Products *products) {
        DDLogVerbose(@"Total products: %lu", (unsigned long)products.data.count);
        if (error == nil)
        {
            if (products.data.count > 0)
            {
                self.products = [NSMutableArray arrayWithArray:products.data];
                self.expiresAt = products.expiresAt;
                self.endOfPrimeTime = products.endOfPrimeTime;
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

- (void)fetchMoreProductsWithCompletion:(void (^)(NSError *))completion
{
    //DO nothing
}

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index
{
    if ((index >= [self numberOfProducts]) || (index == NSNotFound))
    {
        UIStoryboard *discoverStoryboard = [UIStoryboard storyboardWithName:@"DiscoverViews" bundle:[NSBundle mainBundle]];
        LastPageViewController *lastVC = [discoverStoryboard instantiateViewControllerWithIdentifier:@"LastPageView"];
        [lastVC setScrollPageIndex:index];
        [lastVC setLastVideoURL:self.endOfPrimeTime];
        return lastVC;
    }
    
    return [[ProductPageViewController alloc] initWithProduct:[self.products objectAtIndex:index] forContext:kProductContextDiscover];
}

- (NSUInteger)numberOfProducts
{
    return [self.products count];
}

- (BOOL)isExpired
{
    return [[NSDate date] compare:self.expiresAt] == NSOrderedDescending;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = viewController.scrollPageIndex;

    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    else
    {
        return [self productPageViewControllerAtIndex:index - 1];
    }
}

- (UIViewController *)viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[ProductPageViewController class]])
    {
        NSUInteger index = viewController.scrollPageIndex;
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
