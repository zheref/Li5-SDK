//
//  PrimeTimeViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "PrimeTimeViewController.h"

#import "PrimeTimeViewControllerDataSource.h"

@interface PrimeTimeViewController ()
{
    
}

@property (nonatomic,strong) PrimeTimeViewControllerDataSource *source;

@end

@implementation PrimeTimeViewController

@synthesize source;

- (instancetype)init
{
    DDLogVerbose(@"");
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self) {
        self.source = [[PrimeTimeViewControllerDataSource alloc] init];
        self.dataSource = source;
        self.delegate = self;
        [source startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
            if (error != nil) {
                DDLogVerbose(@"ERROR %@", error.description);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if (source.numberOfProducts > 0 )
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
    DDLogInfo(@"Rendering Prime Time Today's Episode");
    // Create page view controller
    
    NSArray *viewControllers = @[[(PrimeTimeViewControllerDataSource*)self.dataSource productPageViewControllerAtIndex:0]];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //Stop spinner
    [[self.view viewWithTag:12] stopAnimating];
}

- (void) renderEndOfPrimeTimeEpisode
{
    DDLogVerbose(@"");
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
        [((ProductPageViewController*)[previousViewControllers lastObject]) hideAndMoveToViewController:[self.viewControllers firstObject]];
        [(ProductPageViewController*)[self.viewControllers firstObject] show];
    }
}



#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
