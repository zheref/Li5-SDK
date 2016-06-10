//
//  LastPageViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "LastPageViewController.h"
#import "ProductsListDynamicInteractor.h"
#import "UserProfileDynamicInteractor.h"
#import "Li5Constants.h"
#import "SwipeDownToExploreViewController.h"

@interface LastPageViewController ()
{
    UIPanGestureRecognizer *profilePanGestureRecognizer;
    UIPanGestureRecognizer *searchPanGestureRecognizer;
    id<UserProfileViewControllerPanTargetDelegate> profileInteractor;
    id<ExploreViewControllerPanTargetDelegate> searchInteractor;
    
    id __swipeDownTimer;
}

@end

@implementation LastPageViewController

@synthesize product;

#pragma mark - Init

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
    
}

#pragma mark - UI Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupObservers];
    
    [self setupGestureRecognizers];
    
}

- (void)presentSwipeDownViewIfNeeded
{
    [self removeObservers];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (TRUE || ![userDefaults boolForKey:kLi5SwipeDownExplainerViewPresented])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DiscoverViews" bundle:[NSBundle mainBundle]];
        SwipeDownToExploreViewController *explainer= [storyboard instantiateViewControllerWithIdentifier:@"SwipeDownExplainerView"];
        explainer.modalPresentationStyle = UIModalPresentationCurrentContext;
        [explainer setSearchInteractor:searchInteractor];
        [self presentViewController:explainer animated:NO completion:^{
            
        }];
    }
}

#pragma mark - Observers

- (void)setupObservers
{
    __swipeDownTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(presentSwipeDownViewIfNeeded) userInfo:nil repeats:NO];
}

- (void)removeObservers
{
    if( __swipeDownTimer)
    {
        [__swipeDownTimer invalidate];
        __swipeDownTimer = nil;
    }
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers
{
    //User Profile Gesture Recognizer - Swipe Down from 0-100px
    profileInteractor = [[UserProfileDynamicInteractor alloc] initWithParentViewController:self];
    profilePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:profileInteractor action:@selector(userDidPan:)];
    [profilePanGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:profilePanGestureRecognizer];
    
    //Search Products Gesture Recognizer - Swipe Down from below 100px
    searchInteractor = [[ProductsListDynamicInteractor alloc] initWithParentViewController:self];
    searchPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:searchInteractor action:@selector(userDidPan:)];
    [searchPanGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:searchPanGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touch = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (gestureRecognizer == profilePanGestureRecognizer)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        return (touch.y < 150) && (velocity.y > 0);
    }
    else if (gestureRecognizer == searchPanGestureRecognizer)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
        return (touch.y >= 150) && (fabs(degree) > 20.0) && (velocity.y > 0);
    }
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([[gestureRecognizer view] isKindOfClass:[UIScrollView class]])
    {
        if (otherGestureRecognizer == profilePanGestureRecognizer || otherGestureRecognizer == searchPanGestureRecognizer)
        {
            return YES;
        }
    }
    return (gestureRecognizer == profilePanGestureRecognizer &&
            (otherGestureRecognizer == searchPanGestureRecognizer));
}


#pragma mark - Displayable Protocol

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    [self removeObservers];
}

#pragma mark - OS Actions

- (void)dealloc
{
    [self removeObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
