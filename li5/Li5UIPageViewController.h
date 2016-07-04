//
//  Li5UIPageViewController.h
//  li5
//
//  Created by Martin Cocaro on 6/24/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "UIViewController+Indexed.h"

typedef enum : NSUInteger {
    Li5UIPageViewControllerDirectionHorizontal,
    Li5UIPageViewControllerDirectionVertical
} Li5UIPageViewControllerDirection;

@protocol Li5UIPageViewControllerDelegate;

@protocol Li5UIPageViewControllerDataSource;

@interface Li5UIPageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) id<Li5UIPageViewControllerDataSource> dataSource;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, weak) id<Li5UIPageViewControllerDelegate> delegate;
@property (nonatomic, assign) Li5UIPageViewControllerDirection direction;
@property (nonatomic, weak) UIViewController *currentViewController;

@property (nonatomic, assign) BOOL bounces;

- (instancetype)initWithDirection:(Li5UIPageViewControllerDirection)direction;

@end

@protocol Li5UIPageViewControllerDelegate

- (void)isSwitchingToPage:(UIViewController*)newPage fromPage:(UIViewController*)oldPage progress:(CGFloat)progress;
- (void)didFinishSwitchingPage:(BOOL)finished;

@end

@protocol Li5UIPageViewControllerDataSource <NSObject>

- (UIViewController *)viewControllerBeforeViewController:(UIViewController *)viewController;

- (UIViewController *)viewControllerAfterViewController:(UIViewController *)viewController;

@end