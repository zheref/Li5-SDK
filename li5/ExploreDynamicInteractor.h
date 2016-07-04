//
//  ProductsListDynamicInteractor.h
//  li5
//
//  Created by Martin Cocaro on 5/9/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ExploreViewController.h"
#import "ProductPageProtocol.h"

@interface ExploreDynamicInteractor : NSObject <ExploreViewControllerPanTargetDelegate>

- (id)initWithParentViewController:(UIViewController<DisplayableProtocol> *)viewController;

@property (nonatomic, readonly, weak) UIViewController<DisplayableProtocol> *parentViewController;

@end
