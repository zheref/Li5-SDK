//
//  RootViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Logger.h"
#import "TeaserViewController.h"
#import "DetailsViewController.h"
#import "ProductPageViewController.h"

@interface RootViewController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,strong) NSMutableArray<ProductPageViewController*> *products;

@end
