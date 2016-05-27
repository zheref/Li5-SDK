//
//  UserLovesViewController.h
//  li5
//
//  Created by Martin Cocaro on 5/21/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductsListView.h"

@interface UserLovesViewController : UIViewController <ProductsListViewDelegate>

@property (weak, nonatomic) IBOutlet ProductsListView *productsListView;

@end
