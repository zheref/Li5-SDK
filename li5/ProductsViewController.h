//
//  ProductsViewController.h
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "ProductsListView.h"
#import "ExploreViewController.h"
//#import "Li5-Swift.h"

@interface ProductsViewController : UIViewController <ProductsListViewDelegate, Li5SearchBarUIViewDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet ProductsListView *productListView;
//@property (nonatomic, strong) ExploreProductInteractor *interactor;

@end
