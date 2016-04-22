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
#import "Li5PageViewController.h"

@interface RootViewController : UIViewController <UIPageViewControllerDelegate>

@property (nonatomic,strong) Li5PageViewController *pageViewController;

@end
