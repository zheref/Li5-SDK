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
#import "Li5Constants.h"

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
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
            DDLogVerbose(@"Total products: %lu expiring:%@", (unsigned long)products.data.count, [dateFormatter stringFromDate:products.expiresAt]);
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
                DDLogError(@"Error retrieving products: %@ %@", error, [error userInfo]);
                //TODO: Only log out user if error 4**
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)error.userInfo[@"com.alamofire.serialization.response.error.response"];
                if (httpResponse.statusCode > 400 && httpResponse.statusCode < 500)
                {
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:kLoggedOutFromServer object:nil];
                }
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

- (ProductPageViewController *)productPageViewControllerAtIndex:(NSUInteger)index withPriority:(BCPriority)priority
{
    ProductPageViewController *controller = [self productPageViewControllerAtIndex:index];
    [controller setPriority:priority];
    return controller;
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


- (UIViewController *)viewControllerViewControllerAtIndex:(NSInteger)index
{
    if ((index < 0) || (index > [self numberOfProducts]) || (index == NSNotFound))
    {
        return nil;
    }
    else
    {
        return [self productPageViewControllerAtIndex:index];
    }
}

@end
