//
//  DetailsViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/20/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductPageProtocol.h"
#import "ShapesHelper.h"
#import "Li5ApiHandler.h"
#import "IndexedViewController.h"

@interface DetailsViewController : UIViewController<LinkedViewControllerProtocol, DisplayableProtocol, UIScrollViewDelegate, UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic, strong) UIViewController *previousViewController;
@property (nonatomic, strong) UIViewController *nextViewController;

@property (nonatomic, strong) Product *product;
@property (nonatomic, strong) UIPageViewController *imagesViewController;
@property (nonatomic, strong) UIPageControl *imagePageControl;
@property (nonatomic, strong) NSMutableArray<IndexedViewController*> *images;

@end
