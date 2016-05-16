//
//  ProductsListDynamicInteractor.m
//  li5
//
//  Created by Martin Cocaro on 5/9/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductsListDynamicInteractor.h"

@interface ProductsListDynamicInteractor ()
{
    ProductsViewController *productsVC;
}

@end

@implementation ProductsListDynamicInteractor

- (id)initWithParentViewController:(UIViewController<DisplayableProtocol> *)viewController
{
    if (!(self = [super init]))
        return nil;
    
    _parentViewController = viewController;
    productsVC = [[ProductsViewController alloc] initWithNibName:@"ProductsViewController" bundle:[NSBundle mainBundle] panTarget:self];
    
    return self;
}

/*
 Note: Unlike when we connect a gesture recognizer to a view via an attachment behaviour,
 our recognizer is going to remain agnostic to how the view controller is presented.
 */
- (void)userDidPan:(UIPanGestureRecognizer *)recognizer
{
    DDLogInfo(@"");
    if (recognizer)
    {
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            DDLogVerbose(@"displaying search");
            [self presentViewWithCompletion:nil];
        }
    }
    else
    {
        DDLogVerbose(@"dismissing search");
        [self dismissViewWithCompletion:nil];
    }
}

- (void)presentViewWithCompletion:(void (^)(void))completion
{
    [self.parentViewController.navigationController pushViewController:productsVC animated:NO];
}

- (void)dismissViewWithCompletion:(void (^)(void))completion
{
    [self.parentViewController.navigationController popViewControllerAnimated:NO];
}

@end
