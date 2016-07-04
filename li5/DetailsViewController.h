//
//  DetailsViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/20/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "ProductPageProtocol.h"
#import "ShapesHelper.h"
#import "IndexedViewController.h"

@interface DetailsViewController : UIViewController<LinkedViewControllerProtocol, DisplayableProtocol, UICollectionViewDataSource, UICollectionViewDelegate>

+ (id)detailsWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx;
+ (id)detailsWithOrder:(Order *)thisOrder andContext:(ProductContext) ctx;

@end
