//
//  RootViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "RootViewController.h"
#import "Li5ApiHandler.h"
#import "ProductPageViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize productPages, pageViewController;

- (instancetype)init
{
    //DDLogVerbose(@"initializing RootController");
    self = [super init];
    if (self) {
        self.productPages = [NSMutableArray array];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            //Background Thread
            Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
            [li5 requestDiscoverProductsWithCompletion:^(NSError *error, NSArray<Product *> *products) {
                NSLog(@"PRODUCTS: %@", products);
                if (error == nil) {
                    [self.productPages addObject:[[ProductPageViewController alloc] initWithProduct:products[0] andIndex:0]];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                        for (int i = 1; i < products.count; i++) {
                            [self.productPages addObject:[[ProductPageViewController alloc] initWithProduct:products[i] andIndex:i]];
                        }
                    });
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        //Run UI Updates
                        [self renderPage];
                    });
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        });
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //DDLogVerbose(@"Loading RootViewController");

    [self.view setBackgroundColor:[UIColor colorWithRed:139.00/255.00 green:223.00/255.00 blue:210.00/255.00 alpha:1.0]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

- (void) renderPage {
    //DDLogVerbose(@"Rendering ProductPageViewController");
    // loop movie
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(replayMovie:)
                                                 name: AVPlayerItemDidPlayToEndTimeNotification
                                               object: nil];
    
    // Create page view controller
    self.pageViewController = [[UIPageViewController alloc ]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    NSArray *viewControllers = @[self.productPages[0]];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //Stop spinner
    [[self.view viewWithTag:12] stopAnimating];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    //DDLogVerbose(@"After transition %d, %d", finished, completed);
    if (finished && completed)
    {
        [((ProductPageViewController*)[previousViewControllers lastObject]) hide];
        [(ProductPageViewController*)[self.pageViewController.viewControllers firstObject] redisplay];
    }
}

-(void)replayMovie:(NSNotification *)notification
{
    [((ProductPageViewController*)[self.pageViewController.viewControllers firstObject]) redisplay];
}

- (UIViewController *)pageViewController:(UIPageViewController *)thisPageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ( thisPageViewController == self.pageViewController )
    {
        NSUInteger index = ((ProductPageViewController*) viewController).index;
        
        if ((index == 0) || (index == NSNotFound))
        {
            return nil;
        }
        return self.productPages[index-1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)thisPageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ( thisPageViewController == self.pageViewController )
    {
        NSUInteger index = ((ProductPageViewController*) viewController).index;
        
        if ((index+1 == [self.productPages count]) || (index == NSNotFound))
        {
            return nil;
        }
        return self.productPages[index+1];
    }
    return nil;
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
