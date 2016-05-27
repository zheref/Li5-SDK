//
//  ProductsListDynamicInteractor.m
//  li5
//
//  Created by Martin Cocaro on 5/9/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductsListDynamicInteractor.h"
#import "ExploreViewController.h"

@interface ProductsListDynamicInteractor ()
{
    ExploreViewController *productsVC;
    
    BOOL presented;
}

@end

@implementation ProductsListDynamicInteractor

- (id)initWithParentViewController:(UIViewController<DisplayableProtocol> *)viewController
{
    if (!(self = [super init]))
        return nil;
    
    _parentViewController = viewController;
    UIStoryboard *searchStoryboard = [UIStoryboard storyboardWithName:@"SearchProductsViews" bundle:[NSBundle mainBundle]];
    productsVC = [searchStoryboard instantiateInitialViewController];
    [productsVC setPanTarget:self];
    
    presented = NO;
    
    return self;
}

/*
 Note: Unlike when we connect a gesture recognizer to a view via an attachment behaviour,
 our recognizer is going to remain agnostic to how the view controller is presented.
 */
- (void)userDidPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint distance = [recognizer translationInView:recognizer.view];
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (fabs(distance.y) > 15)
        {
            if (distance.y > 0 && !presented)
            {
                DDLogVerbose(@"presenting search");
                [self presentViewWithCompletion:nil];
            }
            else
            {
                DDLogVerbose(@"dismissing search");
                [self dismissViewWithCompletion:nil];
            }
        }
    }
}

- (void)presentViewWithCompletion:(void (^)(void))completion
{
    [self.parentViewController.navigationController pushViewController:productsVC animated:NO];
    presented = YES;
}

- (void)dismissViewWithCompletion:(void (^)(void))completion
{
    [self.parentViewController.navigationController popViewControllerAnimated:NO];
    presented = NO;
}

@end
