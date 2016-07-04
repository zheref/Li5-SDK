//
//  PrimeTimeViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import AVFoundation;

#import "PrimeTimeViewController.h"
#import "PrimeTimeViewControllerDataSource.h"
#import "ProductPageProtocol.h"
#import "SpinnerViewController.h"
#import "Li5Constants.h"

@interface PrimeTimeViewController ()
{
    NSInteger startIndex;
    ProductContext pContext;
    
    BOOL __primeTimeLoaded;
    BOOL __spinnerOn;
}

@property (nonatomic, strong) PrimeTimeViewControllerDataSource *primeTimeSource;

@end

@implementation PrimeTimeViewController

@synthesize primeTimeSource;

#pragma mark - Initialization

- (instancetype)initWithDataSource:(PrimeTimeViewControllerDataSource*) source
{
    DDLogVerbose(@"");
    self = [super initWithDirection:Li5UIPageViewControllerDirectionHorizontal];
    if (self)
    {
        self.dataSource = self.primeTimeSource = source;
        startIndex = 0;
        __primeTimeLoaded = NO;
        __spinnerOn = NO;
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self
                               selector:@selector(__popSpinnerScreen)
                                   name:kPrimeTimeLoaded
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(__popSpinnerScreen)
                                   name:kPrimeTimeFailedToLoad
                                 object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DDLogVerbose(@"Loading");
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self renderPrimeTime];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewWillAppear:animated];
    
    [self showSpinnerScreenIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)showSpinnerScreenIfNeeded
{
    DDLogVerbose(@"");
    if (!__primeTimeLoaded && !__spinnerOn)
    {
        UIStoryboard *discoverStoryboard = [UIStoryboard storyboardWithName:@"DiscoverViews" bundle:[NSBundle mainBundle]];
        SpinnerViewController *spinnerScreen = [discoverStoryboard instantiateViewControllerWithIdentifier:@"SpinnerView"];
        [self.navigationController pushViewController:spinnerScreen animated:NO];
        __spinnerOn = YES;
    }
}

- (void)__popSpinnerScreen
{
    DDLogVerbose(@"");
    __primeTimeLoaded = YES;
    if (__spinnerOn)
    {
        [self.navigationController popViewControllerAnimated:NO];
        __spinnerOn = NO;
        
        [self presentExplainerViewsIfNeeded];
    }
}

- (void)presentExplainerViewsIfNeeded
{
    DDLogVerbose(@"");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kLi5SwipeLeftExplainerViewPresented])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DiscoverViews" bundle:[NSBundle mainBundle]];
        UIViewController *explainerView = [storyboard instantiateViewControllerWithIdentifier:@"SwipeLeftExplainerView"];
        
        [self presentViewController:explainerView animated:NO completion:^{
            
        }];
    }
}

#pragma mark - Prime Time Flow

-(void)setStartIndex:(NSInteger)idx
{
    startIndex = idx;
    
    __primeTimeLoaded = YES;
}

- (void)renderPrimeTime
{
    DDLogInfo(@"Rendering Prime Time Today's Episode");
    
    __weak typeof(self) welf = self;
    if (!__primeTimeLoaded)
    {
        [self.primeTimeSource startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
            __strong typeof(self) swelf = welf;
            if (error != nil)
            {
                DDLogVerbose(@"ERROR while Fetching Prime Time %@", error.description);
            }
            
            [swelf __startPrimeTime];
        }];
    }
    else
    {
        [self __startPrimeTime];
    }
}

- (void)__startPrimeTime
{
    // Create page view controller
    UIViewController *viewController = [(PrimeTimeViewControllerDataSource *)self.dataSource productPageViewControllerAtIndex:startIndex];
    [viewController setScrollPageIndex:startIndex];
    [self setViewControllers:@[viewController]];
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
