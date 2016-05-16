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
{
    UIScrollView *containerScrollView;
    CGFloat pageHeight;
    NSInteger currentPage;
    NSInteger fullySwitchedPage;
    NSArray<UIViewController<DisplayableProtocol> *> *viewControllers;
}

@end

@implementation ProductPageViewController

@synthesize index, product;

- (id)initWithProduct:(Product *)thisProduct andIndex:(NSInteger)idx forContext:(ProductContext)context
{
    DDLogVerbose(@"Initializing ProductPageViewController for: %@", thisProduct.title);
    self = [super init];
    if (self)
    {
        self.product = thisProduct;
        self.index = idx;
        pageHeight = 1.0;
        fullySwitchedPage = 0;
        currentPage = 0;
        viewControllers = @[ [[VideoViewController alloc] initWithProduct:self.product andContext:context], [[DetailsViewController alloc] initWithProduct:self.product andContext:context] ];
    }
    return self;
}

- (UIViewController<DisplayableProtocol> *)currentViewController
{
    return viewControllers[currentPage];
}

- (void)setCurrentPage:(NSInteger)page
{
    currentPage = page;
    if (currentPage >= viewControllers.count)
    {
        currentPage = viewControllers.count - 1;
    }

    containerScrollView.delegate = nil;
    containerScrollView.contentOffset = CGPointMake(0.0, (CGFloat)currentPage * self.view.bounds.size.height);
    containerScrollView.delegate = self;
    // Set the fully switched page in order to notify the delegates about it if needed.
    fullySwitchedPage = currentPage;
}

- (void)setFullySwitchedPage:(NSInteger)page
{
    if (fullySwitchedPage != page)
    {
        // The page is fully switched.
        if (fullySwitchedPage < viewControllers.count)
        {
            
            UIViewController<DisplayableProtocol> *previousViewController = viewControllers[fullySwitchedPage];
            // Perform the "disappear" sequence of methods manually when the view of
            // the controller is not visible at all.
            [previousViewController willMoveToParentViewController:self];
            [previousViewController viewWillDisappear:false];
            [previousViewController viewDidDisappear:false];
            [previousViewController didMoveToParentViewController:self];
         
            [self setCurrentPage:page];
            
            UIViewController<DisplayableProtocol> *nextViewController = viewControllers[page];
            //Perform "appear" sequence
            [nextViewController willMoveToParentViewController:self];
            [nextViewController viewWillAppear:false];
            [nextViewController viewDidAppear:false];
            [nextViewController didMoveToParentViewController:self];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    containerScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    containerScrollView.pagingEnabled = true;
    containerScrollView.alwaysBounceVertical = false;
    containerScrollView.showsHorizontalScrollIndicator = false;
    containerScrollView.delegate = self;
    containerScrollView.bounces = false;
    pageHeight = self.view.frame.size.height;
    [self.view addSubview:containerScrollView];

    [self layoutPages];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [viewControllers[currentPage] viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [viewControllers[currentPage] viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    for (int i = 0; i < viewControllers.count; i++)
    {
        CGFloat pageY = ((CGFloat)i) * self.view.bounds.size.height;
        viewControllers[i].view.frame = CGRectMake(0.0, pageY, self.view.bounds.size.width, self.view.bounds.size.height);
    }
    // It is important to set the pageWidth property before the contentSize and contentOffset,
    // in order to use the new width into scrollView delegate methods.
    pageHeight = self.view.bounds.size.height;
    containerScrollView.contentSize = CGSizeMake(1.0, ((CGFloat)viewControllers.count) * self.view.bounds.size.height);
    containerScrollView.contentOffset = CGPointMake(0.0, ((CGFloat)currentPage) * self.view.bounds.size.height);
}

- (void)layoutPages
{
    for (UIView *pageView in containerScrollView.subviews)
    {
        [pageView removeFromSuperview];
    }

    for (int i = 0; i < viewControllers.count; i++)
    {
        UIViewController *page = viewControllers[i];
        [self addChildViewController:page];
        CGRect nextFrame = CGRectMake(self.view.frame.origin.x, ((CGFloat)i) * self.view.bounds.size.height, self.view.frame.size.width, self.view.frame.size.height);
        page.view.frame = nextFrame;
        [containerScrollView addSubview:page.view];
        [page didMoveToParentViewController:self];
    }
    
    containerScrollView.contentSize = CGSizeMake(1.0, self.view.bounds.size.height * ((CGFloat)viewControllers.count));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Update the page when more than 50% of the previous/next page is visible
    NSInteger page = floor((containerScrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    containerScrollView.bounces = (page == (viewControllers.count - 1));
    // Check whether the current view controller is fully presented.
    if (((NSInteger)containerScrollView.contentOffset.y) % ((NSInteger)pageHeight) == 0)
    {
        if (currentPage != page) {
            // Check the page to avoid "index out of bounds" exception.
            if (page >= 0 && page < viewControllers.count) {
                [self setFullySwitchedPage:page];
            }
        }
    }
}

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    [viewControllers[currentPage] hideAndMoveToViewController:viewController];
}

- (void)dealloc
{
    DDLogDebug(@"no longer needed %lu", (unsigned long)[self index]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
