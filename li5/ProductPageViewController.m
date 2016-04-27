//
//  ProductPageViewController.m
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductPageViewController.h"
#import "VideoViewController.h"

@interface ProductPageViewController ()

@property (nonatomic, strong) VideoViewController *videoViewController;
@property (nonatomic, strong) DetailsViewController *detailsViewController;

@end

@implementation ProductPageViewController

@synthesize index, product, detailsViewController, videoViewController;

- (id)initWithProduct:(Product *)thisProduct andIndex:(NSInteger)idx
{
    DDLogVerbose(@"Initializing ProductPageViewController for: %@", thisProduct.title);
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    if (self)
    {
        self.product = thisProduct;
        self.index = idx;
        self.dataSource = self;
        self.delegate = self;
        self.videoViewController = [[VideoViewController alloc] initWithProduct:self.product];
        self.detailsViewController = [[DetailsViewController alloc] initWithProduct:self.product];

        [videoViewController setNextViewController:detailsViewController];
        [detailsViewController setPreviousViewController:videoViewController];

        NSArray *viewControllers = @[ videoViewController ];
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scrollView = (UIScrollView *)view;
            scrollView.delaysContentTouches = false;
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    //DDLogVerbose(@"After transition %d, %d", finished, completed);
    if (self == pageViewController && finished && completed)
    {
        [((UIViewController<DisplayableProtocol> *)[previousViewControllers lastObject]) hideAndMoveToViewController:[pageViewController.viewControllers firstObject]];
        [((UIViewController<DisplayableProtocol> *)[pageViewController.viewControllers firstObject])show];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (pageViewController == self)
    {
        return [(UIViewController<LinkedViewControllerProtocol> *)viewController previousViewController];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (pageViewController == self)
    {
        return [(UIViewController<LinkedViewControllerProtocol> *)viewController nextViewController];
    }
    return nil;
}

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    [((UIViewController<DisplayableProtocol> *)[self.viewControllers firstObject]) hideAndMoveToViewController:viewController];
}

- (void)show
{
    [((UIViewController<DisplayableProtocol> *)[self.viewControllers firstObject])show];
}

- (void)redisplay
{
    [((UIViewController<DisplayableProtocol> *)[self.viewControllers firstObject])redisplay];
}

- (void)dealloc
{
    DDLogDebug(@"no longer needed");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
