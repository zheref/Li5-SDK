//
//  ProductsViewController.h
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductsListView.h"
#import "ExploreViewController.h"

@interface ProductsViewController : UIViewController <ProductsListViewDelegate, Li5SearchBarUIViewDelegate>

@property (weak, nonatomic) IBOutlet ProductsListView *productListView;

@end