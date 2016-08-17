//
//  PrimeTimeViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import TSMessages;
@import AVFoundation;
@import BCVideoPlayer;

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
    
    NSOperationQueue *__queue;
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
        __queue = [[NSOperationQueue alloc] init];
        [__queue setName:@"Prime Time Queue"];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self
                               selector:@selector(__popSpinnerScreen)
                                   name:kPrimeTimeLoaded
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
        [__queue addOperationWithBlock:^{
            [welf.primeTimeSource startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
                __strong typeof(self) swelf = welf;
                if (error != nil)
                {
                    DDLogError(@"ERROR while Fetching Prime Time %@", error.localizedDescription);
                    
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:kPrimeTimeFailedToLoad object:nil];

                    [TSMessage showNotificationWithTitle:@"Something went wrong"
                                                subtitle:error.localizedDescription
                                                    type:TSMessageNotificationTypeError];
                }
                else
                {
                    [swelf __startPrimeTime];
                }
            }];
        }];
    }
    else
    {
//        [__queue addOperationWithBlock:^{
            [welf __startPrimeTime];
//        }];
    }
}

- (void)__startPrimeTime
{
    // Create page view controller
    UIViewController *viewController = [(PrimeTimeViewControllerDataSource *)self.dataSource productPageViewControllerAtIndex:startIndex withPriority:BCPriorityBuffer];
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
