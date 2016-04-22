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
#import "RootViewControllerDataSource.h"

@interface RootViewController ()

@property (nonatomic, strong) RootViewControllerDataSource *dataSource;

@end

@implementation RootViewController

@synthesize pageViewController;

- (instancetype)init
{
    //DDLogVerbose(@"initializing RootController");
    self = [super init];
    if (self) {
        
        self.dataSource = [[RootViewControllerDataSource alloc] init];
        [self.dataSource startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
            if (error != nil) {
                DDLogVerbose(@"ERROR");
            } else {
                DDLogVerbose(@"OK");
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self renderPage];
                });
            }
        }];
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

- (void)renderPage {
    //DDLogVerbose(@"Rendering ProductPageViewController");
    // loop movie
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(replayMovie:)
                                                 name: AVPlayerItemDidPlayToEndTimeNotification
                                               object: nil];
    
    // Create page view controller
    self.pageViewController = [[Li5PageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self.dataSource;
    self.pageViewController.delegate = self;
    
    NSArray *viewControllers = @[[self.dataSource productPageViewControllerAtIndex:0]];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //Stop spinner
    [[self.view viewWithTag:12] stopAnimating];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.dataSource productPageViewControllerAtIndex:1];
    });
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
        [((ProductPageViewController*)[previousViewControllers lastObject]) hideAndMoveToViewController:[self.pageViewController.viewControllers firstObject]];
        [(ProductPageViewController*)[self.pageViewController.viewControllers firstObject] redisplay];
    }
}

#pragma mark - Helpers

- (void)replayMovie:(NSNotification *)notification
{
    [((ProductPageViewController*)[self.pageViewController.viewControllers firstObject]) redisplay];
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
