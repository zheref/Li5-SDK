//
//  PrimeTimeViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "PrimeTimeViewController.h"
#import "PrimeTimeViewControllerDataSource.h"
#import "ProductPageProtocol.h"

@interface PrimeTimeViewController ()
{
    NSInteger startIndex;
    ProductContext pContext;
}

@property (nonatomic, strong) PrimeTimeViewControllerDataSource *primeTimeSource;

@end

@implementation PrimeTimeViewController

@synthesize primeTimeSource;

#pragma mark - Initialization

- (instancetype)initWithDataSource:(PrimeTimeViewControllerDataSource*) source
{
    DDLogVerbose(@"");
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self)
    {
        self.dataSource = self.primeTimeSource = source;
        self.delegate = self;
        startIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DDLogVerbose(@"Loading");

    [self renderPrimeTime];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Prime Time Flow

-(void)setStartIndex:(NSInteger)idx
{
    startIndex = idx;
}

- (void)renderPrimeTime
{
    DDLogInfo(@"Rendering Prime Time Today's Episode");
    
    // Create page view controller
    NSArray *viewControllers = @[ [(PrimeTimeViewControllerDataSource *)self.dataSource productPageViewControllerAtIndex:startIndex] ];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    DDLogVerbose(@"After transition %d, %d", finished, completed);
    if (finished && completed)
    {
        [((UIViewController<DisplayableProtocol>*)[previousViewControllers lastObject]) hideAndMoveToViewController:[self.viewControllers firstObject]];
    }
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
