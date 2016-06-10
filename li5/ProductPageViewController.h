//
//  ProductPageViewController.h
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "DetailsViewController.h"
#import "VideoViewController.h"

@interface ProductPageViewController : UIViewController <UIScrollViewDelegate, DisplayableProtocol>

@property NSUInteger index;

- (id)initWithProduct:(Product *)thisProduct andIndex:(NSInteger)idx forContext:(ProductContext)context;
- (id)initWithOrder:(Order *)thisProduct andIndex:(NSInteger)idx forContext:(ProductContext)context;

- (UIViewController<DisplayableProtocol>*) currentViewController;

@end
