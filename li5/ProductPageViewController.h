//
//  ProductPageViewController.h
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "DetailsViewController.h"
#import "Li5ApiHandler.h"
#import "VideoViewController.h"

@interface ProductPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, DisplayableProtocol, UIGestureRecognizerDelegate>

@property NSUInteger index;

@property (nonatomic, strong) Product *product;

- (id)initWithProduct:(Product *)thisProduct andIndex:(NSInteger)idx;

@end
