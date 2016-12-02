//
//  ProductsListDynamicInteractor.h
//  li5
//
//  Created by Martin Cocaro on 5/9/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "ExploreViewController.h"
#import "ProductPageProtocol.h"

@interface ExploreDynamicInteractor : UIPercentDrivenInteractiveTransition <ExploreViewControllerPanTargetDelegate, UIViewControllerTransitioningDelegate>

-(id)initWithParentViewController:(UIViewController *)triggeringViewController;

@end
