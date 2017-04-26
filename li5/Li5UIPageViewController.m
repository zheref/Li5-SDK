//
//  Li5UIPageViewController.m
//  li5
//
//  Created by Martin Cocaro on 6/24/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "Li5UIPageViewController.h"

typedef NS_OPTIONS(NSUInteger, ScrollDirection) {
    ScrollDirectionNone = 0,
    ScrollDirectionRight = 1 << 0,
    ScrollDirectionLeft = 1 << 1,
    ScrollDirectionUp = 1 << 2,
    ScrollDirectionDown = 1 << 3
};

@interface Li5UIPageViewController () {
    NSOperationQueue *__queue;
    
    ScrollDirection __scrollDirection;
    BOOL __preloading;
}

@property (nonatomic, strong) UIScrollView *containerScrollView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger fullySwitchedPage;
@property (nonatomic, assign) CGFloat pageLength;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger cacheSize;

@property (nonatomic, weak) UIViewController *previousViewController;
@property (nonatomic, weak) UIViewController *nextViewController;

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation Li5UIPageViewController

- (instancetype)initWithDirection:(Li5UIPageViewControllerDirection)direction
{
    self = [super init];
    if (self)
    {
        _direction = direction;
        [self initialize];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _fullySwitchedPage = 0;
    _currentPage = 0;
    _viewControllers = [NSArray array];
    _dataSource = nil;
    _totalPages = 0;
    _bounces = YES;
    __queue = [[NSOperationQueue alloc] init];
    [__queue setName:@"Page View Queue"];
}

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.containerScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.containerScrollView.pagingEnabled = true;
    self.containerScrollView.alwaysBounceVertical = false;
    self.containerScrollView.showsHorizontalScrollIndicator = false;
    self.containerScrollView.showsVerticalScrollIndicator = false;
    self.containerScrollView.delegate = self;
    self.containerScrollView.bounces = false;
    _pageLength = (_direction == Li5UIPageViewControllerDirectionVertical ? self.view.bounds.size.height : self.view.bounds.size.width);
    [self.view addSubview:self.containerScrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogVerbose(@"%p",self);
    [super viewWillAppear:animated];
    
    [self.currentViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"%p",self);
    [super viewDidAppear:animated];
    
    [self.currentViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DDLogVerbose(@"%p",self);
    [super viewWillDisappear:animated];
    
    [self.currentViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"%p",self);
    [super viewDidDisappear:animated];
    
    [self.currentViewController endAppearanceTransition];
}

// From the container view controller
- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)setCurrentPage:(NSInteger)page
{
    DDLogVerbose(@"");
    _currentPage = page;
    if (_currentPage >= self.totalPages)
    {
        _currentPage = self.totalPages - 1;
    }
    
    [self __updateScrollViewContents];
    // Set the fully switched page in order to notify the delegates about it if needed.
    _fullySwitchedPage = _currentPage;
}

- (void)__updateScrollViewContents
{
    DDLogVerbose(@"");
    self.containerScrollView.delegate = nil;
    self.pageLength = (self.direction == Li5UIPageViewControllerDirectionVertical ? self.view.bounds.size.height : self.view.bounds.size.width);
    self.containerScrollView.contentSize = CGSizeMake(
                                                      self.direction == Li5UIPageViewControllerDirectionHorizontal ? ((CGFloat)self.totalPages) * self.view.bounds.size.width : 1.0,
                                                      self.direction == Li5UIPageViewControllerDirectionVertical ? ((CGFloat)self.totalPages) * self.view.bounds.size.height : 1.0);
    
    self.containerScrollView.contentOffset = CGPointMake(
                                                         self.direction == Li5UIPageViewControllerDirectionHorizontal ? ((CGFloat)self.currentPage) * self.view.bounds.size.width : 0.0,
                                                         self.direction == Li5UIPageViewControllerDirectionVertical ? ((CGFloat)self.currentPage) * self.view.bounds.size.height : 0.0);
    self.containerScrollView.delegate = self;
}

- (void)setFullySwitchedPage:(NSInteger)page
{
    DDLogVerbose(@"");
    if (self.fullySwitchedPage != page)
    {
        // The page is fully switched.
        if (self.fullySwitchedPage < self.totalPages)
        {
            NSInteger previousPage = self.currentPage;
            
            _previousViewController = [self __getViewControllerWithPage:previousPage];
            _currentViewController = [self __getViewControllerWithPage:page];
            //
            
            if(_currentViewController.parentViewController == nil) {
                [self __presentViewController:_currentViewController];
            }
//
            if(_previousViewController.parentViewController == nil) {
                [self __presentViewController:_previousViewController];
            }
            //
            
            // Perform the "disappear" sequence of methods manually when the view of
            // the controller is not visible at all.
            [_previousViewController willMoveToParentViewController:self];
            [_previousViewController viewWillDisappear:false];
            [_previousViewController viewDidDisappear:false];
            [_previousViewController didMoveToParentViewController:self];
            
            //Change to current page
            [self setCurrentPage:page];
            
            //Perform "appear" sequence
            [_currentViewController willMoveToParentViewController:self];
            [_currentViewController viewWillAppear:false];
            [_currentViewController viewDidAppear:false];
            [_currentViewController didMoveToParentViewController:self];
        }
    }
}

- (void)setVisiblePage:(NSInteger)page
{
    [self preloadViewController:page];
    [self setFullySwitchedPage:page];
    if (self.delegate) {
        [self.delegate didFinishSwitchingPage:YES];
    }
}

- (BOOL)isLeftDown {
    
    return __scrollDirection & ScrollDirectionLeft || __scrollDirection & ScrollDirectionDown;
}

- (void)preloadViewController:(NSInteger)page {
    
    if (self.dataSource == nil || __preloading) {
        return;
    }
    
    for (UIViewController *vc in self.viewControllers) {
        if (vc.scrollPageIndex == page) {
            return;
        }
    }
    
    __preloading = true;
    
    //    [__queue addOperationWithBlock:^{
    UIViewController *nextViewController = [self.dataSource viewControllerViewControllerAtIndex:page];
    if (nextViewController != nil)
    {
//                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [nextViewController setScrollPageIndex:page];
        
        if (page >= self.totalPages)
        {
            self.totalPages++;
        }
        
        //
        NSMutableArray *array = [NSMutableArray array];
        
        if([self isLeftDown]) {
            
            if(_previousViewController != nil) {
                [array addObject:_previousViewController];
            }
            
            if(_currentViewController != nil) {
                [array addObject:_currentViewController];
            }
            
            [array addObject:nextViewController];
        }
        else {
            
            [array addObject:nextViewController];
            
            if(_currentViewController != nil) {
                [array addObject:_currentViewController];
            }
            if(_previousViewController != nil) {
                [array addObject:_previousViewController];
            }
            
            //            _viewControllers = @[nextViewController, _currentViewController, _previousViewController];
        }
        
        _viewControllers = [NSArray arrayWithArray:array];
        
        if(nextViewController.parentViewController == nil) {
            [self __presentViewController:nextViewController];
        }
        
        [self __cleanViewControllers];
        __preloading = false;
//                    }];
    }else {
        
        __preloading = false;
    }
    //    }];
}

- (UIViewController*)__getViewControllerWithPage:(NSInteger)page
{
    //    DDLogVerbose(@"");
    for (UIViewController *vc in self.viewControllers) {
        if (vc.scrollPageIndex == page) {
            return vc;
        }
    }
    
    UIViewController *vc = [self.dataSource viewControllerViewControllerAtIndex:page];
    vc.scrollPageIndex = page;
    
    if(vc == nil) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:_viewControllers];
    [array addObject:vc];
    _viewControllers = [NSArray arrayWithArray:array];
    //    [self __presentViewController:vc];
    
    return vc;
}

- (void)__cleanViewControllers
{
    DDLogVerbose(@"");
    for (UIViewController *childController in self.childViewControllers)
    {
        if (![self.viewControllers containsObject:childController])
        {
            if(_currentViewController != childController) {
                [childController.view removeFromSuperview];
                [childController removeFromParentViewController];
            }
        }
    }
}

- (void)viewDidLayoutSubviews
{
    DDLogVerbose(@"");
//    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
//    for (UIView *pageView in self.containerScrollView.subviews)
//    {
//        [pageView removeFromSuperview];
//    }
    
    for (int i = 0; i < self.viewControllers.count; i++)
    {
        UIViewController *page = self.viewControllers[i];
        if (page != nil)
        {
            [self addChildViewController:page];
            CGRect nextFrame = CGRectMake(
                                          (self.direction == Li5UIPageViewControllerDirectionVertical ? self.view.bounds.origin.x : ((CGFloat)page.scrollPageIndex) * self.view.bounds.size.width),
                                          (self.direction == Li5UIPageViewControllerDirectionHorizontal ? self.view.bounds.origin.y : ((CGFloat)page.scrollPageIndex) * self.view.bounds.size.height),
                                          self.view.bounds.size.width,
                                          self.view.bounds.size.height);
            page.view.frame = nextFrame;
            [self.containerScrollView addSubview:page.view];
            [page didMoveToParentViewController:self];
        }
    }
    
    [self __updateScrollViewContents];
}

- (void)__presentViewController:(UIViewController*)page
{
    DDLogVerbose(@"");
    if (page != nil)
    {
        [self addChildViewController:page];
        CGRect nextFrame = CGRectMake(
                                      (self.direction == Li5UIPageViewControllerDirectionVertical ? self.view.bounds.origin.x : ((CGFloat)page.scrollPageIndex) * self.view.bounds.size.width),
                                      (self.direction == Li5UIPageViewControllerDirectionHorizontal ? self.view.bounds.origin.y : ((CGFloat)page.scrollPageIndex) * self.view.bounds.size.height),
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height);
        page.view.frame = nextFrame;
        [self.containerScrollView addSubview:page.view];
        [page didMoveToParentViewController:self];
    }
    
    [self __updateScrollViewContents];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    DDLogDebug(@"");
    __scrollDirection = ScrollDirectionNone;
    
    if (self.direction == Li5UIPageViewControllerDirectionHorizontal)
    {
        if (self.lastContentOffset > scrollView.contentOffset.x)
            __scrollDirection = ScrollDirectionRight;
        else if (self.lastContentOffset < scrollView.contentOffset.x)
            __scrollDirection = ScrollDirectionLeft;
        self.lastContentOffset = scrollView.contentOffset.x;
    }
    else
    {
        if (self.lastContentOffset > scrollView.contentOffset.y)
            __scrollDirection = ScrollDirectionDown;
        else if (self.lastContentOffset < scrollView.contentOffset.y)
            __scrollDirection = ScrollDirectionUp;
        self.lastContentOffset = scrollView.contentOffset.y;
    }
    
    // Update the page when more than 50% of the previous/next page is visible
    NSInteger page = floor(((self.direction == Li5UIPageViewControllerDirectionVertical ? self.containerScrollView.contentOffset.y : self.containerScrollView.contentOffset.x) - self.pageLength / 2) / self.pageLength) + 1;
    self.containerScrollView.bounces = (self.bounces && page == (self.totalPages - 1));
    
    double progress = (self.direction == Li5UIPageViewControllerDirectionVertical ? self.containerScrollView.contentOffset.y : self.containerScrollView.contentOffset.x) / self.pageLength;
    NSInteger fullNextPage = ceil(progress);
    NSInteger fullPrevPPage = floor(progress);
    
    if (self.delegate)
    {
        double percentage = fmod(progress, 1.0);
        
        UIViewController *prevController = nil;
        UIViewController *nextController = nil;
        
        if([self isLeftDown])
        {
            prevController = [self __getViewControllerWithPage:fullPrevPPage];
            nextController = [self __getViewControllerWithPage:fullNextPage];
            
            progress = percentage;
        }
        else
        {
            prevController = [self __getViewControllerWithPage:fullNextPage];
            nextController = [self __getViewControllerWithPage:fullPrevPPage];
            
            progress = 1 - percentage;
        }
        
        if (!percentage)
        {
            progress = 1.0;
        }
        
        [self.delegate isSwitchingToPage:nextController fromPage:prevController progress:progress];
    }
    
    if(!self.delegate && !__preloading) {
        
        NSInteger pageToPreload = self.currentPage;
        
        if([self isLeftDown]) {
            pageToPreload = fullNextPage;
        }
        else {
            pageToPreload = fullPrevPPage;
        }
//               [__queue addOperationWithBlock:^{
        [self preloadViewController:pageToPreload];
//               }];
    }
    
    // Check whether the current view controller is fully presented.
    if (((NSInteger)(self.direction == Li5UIPageViewControllerDirectionVertical ? self.containerScrollView.contentOffset.y : self.containerScrollView.contentOffset.x)) % ((NSInteger)self.pageLength) == 0)
    {
        if (self.currentPage != page)
        {
            // Check the page to avoid "index out of bounds" exception.
            if (page >= 0 && page < self.totalPages)
            {
                [self setFullySwitchedPage:page];
                
                if (self.delegate)
                {
                    if([self isLeftDown]) {   [self preloadViewController:page + 1];
                    }else {
                    
                      [self preloadViewController:page - 1];
                    }
                  
                    [self.delegate didFinishSwitchingPage:YES];
                }
            }
        }
        
    }
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
{
    DDLogVerbose(@"");
    _currentPage = viewControllers.firstObject.scrollPageIndex;
    _fullySwitchedPage = _currentPage;
    _currentViewController = viewControllers.firstObject;
    if (self.dataSource != nil)
    {
        _viewControllers = [NSArray arrayWithArray:[self __preloadAfterViewController:[self __preloadPreviousViewController:viewControllers]]];
        _totalPages = MAX(_viewControllers.lastObject.scrollPageIndex + 1, [_viewControllers count]);
    }
    else
    {
        _viewControllers = viewControllers;
        for (int i = (int)_currentPage; i < _viewControllers.count; i++) {
            [_viewControllers[i] setScrollPageIndex:i];
        }
        _totalPages = [_viewControllers count];
    }
}

- (NSArray<UIViewController *> *)__preloadPreviousViewController:(NSArray<UIViewController *> *)viewControllers
{
    DDLogVerbose(@"");
    UIViewController *previousViewController = [self.dataSource viewControllerBeforeViewController:[viewControllers firstObject]];
    [previousViewController setScrollPageIndex:viewControllers.firstObject.scrollPageIndex-1];
    
    NSMutableArray *controllers = [NSMutableArray array];
    if (previousViewController != nil)
        [controllers addObject:previousViewController];
    if (viewControllers != nil)
        [controllers addObjectsFromArray:viewControllers];
    
    return controllers;
}

- (NSArray<UIViewController *> *)__preloadAfterViewController:(NSArray<UIViewController *> *)viewControllers
{
    DDLogVerbose(@"");
    UIViewController *nextViewController = [self.dataSource viewControllerAfterViewController:[viewControllers lastObject]];
    [nextViewController setScrollPageIndex:viewControllers.lastObject.scrollPageIndex+1];
    
    NSMutableArray *controllers = [NSMutableArray array];
    if (viewControllers != nil)
        [controllers addObjectsFromArray:viewControllers];
    if (nextViewController != nil)
        [controllers addObject:nextViewController];
    
    return controllers;
}


@end