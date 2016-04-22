//
//  ProductPageViewController.m
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductPageViewController.h"

@interface ProductPageViewController ()

@end

@implementation ProductPageViewController

@synthesize index, product, teaserViewController, detailsViewController;

- (id)initWithProduct:(Product *)thisProduct andIndex:(NSInteger)idx
{
    DDLogVerbose(@"Initializing ProductPageViewController for: %@", thisProduct.title);
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    if (self) {
        self.product = thisProduct;
        self.index = idx;
        self.dataSource = self;
        self.delegate = self;
        self.teaserViewController = [[TeaserViewController alloc] initWithProduct:self.product];
        self.detailsViewController = [[DetailsViewController alloc] initWithProduct:self.product];
        
        [teaserViewController setNextViewController:detailsViewController];
        [detailsViewController setPreviousViewController:teaserViewController];
                
        NSArray *viewControllers = @[self.teaserViewController];
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
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
        [((LinkedViewController<DisplayableProtocol>*)[previousViewControllers lastObject]) hideAndMoveToViewController:[pageViewController.viewControllers firstObject]];
        [((LinkedViewController<DisplayableProtocol>*)[pageViewController.viewControllers firstObject]) show];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ( pageViewController == self )
    {
        return [(LinkedViewController*)viewController previousViewController];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ( pageViewController == self )
    {
        return [(LinkedViewController*)viewController nextViewController];
    }
    return nil;
}

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    [((LinkedViewController<DisplayableProtocol>*)[self.viewControllers firstObject]) hideAndMoveToViewController:viewController];
}

- (void)show
{
    [((LinkedViewController<DisplayableProtocol>*)[self.viewControllers firstObject]) show];
}

- (void)redisplay
{
    [((LinkedViewController<DisplayableProtocol>*)[self.viewControllers firstObject]) redisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
