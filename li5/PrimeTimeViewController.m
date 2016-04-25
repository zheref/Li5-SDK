//
//  PrimeTimeViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "PrimeTimeViewController.h"

#import "RootViewControllerDataSource.h"

@interface PrimeTimeViewController ()

@property (nonatomic, strong) RootViewControllerDataSource *dataSource;

@end

@implementation PrimeTimeViewController

@synthesize pageViewController;

- (instancetype)init
{
    //DDLogVerbose(@"initializing RootController");
    self = [super init];
    if (self) {
        self.dataSource = [[RootViewControllerDataSource alloc] init];
        [self.dataSource startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
            if (error != nil) {
                DDLogVerbose(@"ERROR %@", error.description);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if ( self.dataSource.numberOfProducts > 0 )
                    {
                        [self renderPrimeTime];
                    } else {
                        [self renderEndOfPrimeTimeEpisode];
                    }
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
    
    [self.view setBackgroundColor:[UIColor redColor]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

- (void)renderPrimeTime {
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
    
}

- (void) renderEndOfPrimeTimeEpisode
{
    //Stop spinner
    [[self.view viewWithTag:12] stopAnimating];
    
    //Message
    NSString *errorMessage = @"There are no more products to view. Come back tomorrow!";
    UIFont *errorMessageFont = [UIFont fontWithName:@"Avenir" size:14];
    CGRect errorMessageSize = [errorMessage boundingRectWithSize:CGSizeMake(self.view.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:errorMessageFont} context:nil];
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,self.view.center.y,errorMessageSize.size.width,errorMessageSize.size.height)];
    errorLabel.center = self.view.center;
    [errorLabel setTextColor:[UIColor whiteColor]];
    [errorLabel setNumberOfLines:0];
    [errorLabel setFont:errorMessageFont];
    [errorLabel setText:errorMessage];
    [errorLabel setTextAlignment: NSTextAlignmentCenter];
    [self.view addSubview:errorLabel];
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
