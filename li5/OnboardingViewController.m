//
//  OnboardingViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/30/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import SMPageControl;

#import "OnboardingViewController.h"
#import "LoginViewController.h"
#import "OnboardingPageContentViewController.h"
#import <objc/runtime.h>

@interface OnboardingViewController ()

@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet SMPageControl *pageControl;

@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageSubtitles;

@end

@implementation OnboardingViewController

#pragma mark - UI Setup

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OnboardingViews" bundle:[NSBundle mainBundle]];
    self = [storyboard instantiateInitialViewController];
    if (self) {
        //Do nothing since initialize is called by storybaord initWithCoder
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _pageTitles = @[@"Discover New",@"Explore Products"];
    _pageSubtitles = @[@"Presented in short videos",@"This is the second description"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pageControl.numberOfPages = 3;
    _pageControl.indicatorMargin = 10.0;
    _pageControl.indicatorDiameter = 16.0;
    [_pageControl sizeToFit];
    
    NSArray *viewControllers = @[[self viewControllerAtIndex:0]];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"pageViewEmbed"])
    {
        _pageViewController = (UIPageViewController*)[segue destinationViewController];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return TRUE;
}

#pragma mark - PageViewControllerDataSource

- (UIViewController*)viewControllerAtIndex:(NSInteger)index
{
    if (([self.pageTitles count] == 0) || (index == [self.pageTitles count])) {
        
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardingLoginView"];
        objc_setAssociatedObject(vc, @selector(pageIndex), [NSNumber numberWithInteger:index], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return vc;
    }
    
    if (index > [self.pageTitles count])
    {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    OnboardingPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardingPageContentView"];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.subtitleText = self.pageSubtitles[index];
    
    objc_setAssociatedObject(pageContentViewController, @selector(pageIndex), [NSNumber numberWithInteger:index], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return pageContentViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [objc_getAssociatedObject(viewController, @selector(pageIndex)) integerValue];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [objc_getAssociatedObject(viewController, @selector(pageIndex)) integerValue];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    return [self viewControllerAtIndex:index];
}

#pragma mark - PageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished && completed)
    {
        NSUInteger index = [objc_getAssociatedObject(pageViewController.viewControllers.firstObject, @selector(pageIndex)) integerValue];
        _pageControl.currentPage = index;
    }
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
