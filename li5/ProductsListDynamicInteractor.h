//
//  ProductsListDynamicInteractor.h
//  li5
//
//  Created by Martin Cocaro on 5/9/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductsViewController.h"
#import "ProductPageProtocol.h"

@interface ProductsListDynamicInteractor : NSObject <ProductsViewControllerPanTargetDelegate>

- (id)initWithParentViewController:(UIViewController<DisplayableProtocol> *)viewController;

@property (nonatomic, readonly, weak) UIViewController<DisplayableProtocol> *parentViewController;

@end
