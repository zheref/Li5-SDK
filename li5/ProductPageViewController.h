//
//  ProductPageViewController.h
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Logger.h"
#import "Product.h"
#import "TeaserViewController.h"
#import "DetailsViewController.h"

@interface ProductPageViewController : UIPageViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate, DisplayableProtocol>

@property NSUInteger index;

@property (nonatomic,strong) Product *product;
@property (nonatomic,strong) TeaserViewController *teaserViewController;
@property (nonatomic,strong) DetailsViewController *detailsViewController;

- (id)initWithProduct:(Product *) thisProduct andIndex: (NSInteger) idx;

@end
