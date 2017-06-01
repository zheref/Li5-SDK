//
//  PrimeTimeViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/23/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
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
    BOOL __primeTimeLoading;
    
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
        __primeTimeLoading = NO;
        __queue = [[NSOperationQueue alloc] init];
        [__queue setName:@"Prime Time Queue"];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self
                               selector:@selector(__popSpinnerScreen)
                                   name:kPrimeTimeLoaded
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(renderPrimeTime)
                                   name:kFetchPrimeTime
                                 object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DDLogVerbose(@"Loading");
    
    [self.view setBackgroundColor: [UIColor clearColor]];
    self.view.opaque = false;
    
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
    NSLog(@"PrimeTime did appear");
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"");
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)showSpinnerScreenIfNeeded
{
    DDLogVerbose(@"");
    if (!__primeTimeLoaded && !__spinnerOn)
    {
        __spinnerOn = YES;
    }
}

- (void)__popSpinnerScreen
{
    DDLogVerbose(@"");
    __primeTimeLoaded = YES;
    if (__spinnerOn)
    {
        __spinnerOn = NO;
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
    NSLog(@"Rendering Prime Time Today's Episode");
    
    __weak typeof(self) welf = self;
    if (!__primeTimeLoading) {
        if (!__primeTimeLoaded)
        {
            [__queue addOperationWithBlock:^{
                __primeTimeLoading = YES;
                [welf.primeTimeSource startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
                    __primeTimeLoading = NO;
                    __strong typeof(self) swelf = welf;
                    if (error != nil)
                    {
                        DDLogError(@"ERROR while Fetching Prime Time %@", error.localizedDescription);
                        [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
                        
                        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                        [notificationCenter postNotificationName:kPrimeTimeFailedToLoad object:error];
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
}

- (void)__startPrimeTime
{
    // Create page view controller
    UIViewController *viewController = [(PrimeTimeViewControllerDataSource *)self.dataSource productPageViewControllerAtIndex:startIndex withPriority:BCPriorityBuffer];
    [viewController setScrollPageIndex:startIndex];
    [self setViewControllers:@[viewController]];
    [self viewDidLayoutSubviews];
    
    [viewController beginAppearanceTransition:YES animated:NO];
    [viewController endAppearanceTransition];
}

#pragma mark - OS Actions

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.currentViewController.view.frame = self.view.bounds;
}

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

@implementation PrimeTimeNavigationViewController

- (BOOL)prefersStatusBarHidden {
    return [self.topViewController prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    DDLogVerbose(@"");
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    DDLogVerbose(@"");
    return self.topViewController;
}

@end
