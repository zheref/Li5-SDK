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

@interface LastPageViewController ()
{
    UIPanGestureRecognizer *profilePanGestureRecognizer;
    UIPanGestureRecognizer *searchPanGestureRecognizer;
    id<UserProfileViewControllerPanTargetDelegate> profileInteractor;
    id<ProductsViewControllerPanTargetDelegate> searchInteractor;
}

@end

@implementation LastPageViewController

@synthesize product;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupGestureRecognizers];
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
    //Do nothing, last item in prime time
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
