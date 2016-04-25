//
//  DetailsViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/20/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "LinkedViewController.h"
#import "ShapesHelper.h"
#import "Li5ApiHandler.h"
#import "IndexedViewController.h"

@interface DetailsViewController : LinkedViewController<UIScrollViewDelegate, DisplayableProtocol, UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic, strong) Product *product;
@property (nonatomic, strong) UIPageViewController *imagesViewController;
@property (nonatomic, strong) UIPageControl *imagePageControl;
@property (nonatomic, strong) NSMutableArray<IndexedViewController*> *images;

- (id) initWithProduct:(Product *) thisProduct;

@end
