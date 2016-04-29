//
//  VideoViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5ApiHandler.h"
#import "TeaserViewController.h"
#import "UnlockedViewController.h"
#import "VideoViewController.h"

@interface VideoViewController ()
{
    TeaserViewController *teaserViewController;
    UnlockedViewController *unlockedViewController;
    UIViewController<DisplayableProtocol> *currentViewController;
}

@end

@implementation VideoViewController

@synthesize product, previousViewController, nextViewController;

- (id)initWithProduct:(Product *)thisProduct
{
    self = [super init];
    if (self)
    {
        //DDLogVerbose(@"Initializing DetailsViewController for: %@", thisProduct.title);
        self.product = thisProduct;
        teaserViewController = [[TeaserViewController alloc] initWithProduct:self.product];
        if (self.product.videoURL != nil && self.product.videoURL.length > 0)
        {
            unlockedViewController = [[UnlockedViewController alloc] initWithProduct:self.product];
        }
        currentViewController = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self showViewController:teaserViewController];
}

- (void)hideViewController:(UIViewController<DisplayableProtocol> *)vc
{
    [vc hideAndMoveToViewController:nil];
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}

- (void)showViewController:(UIViewController<DisplayableProtocol> *)vc
{
    [self addChildViewController:vc];
    vc.view.frame = self.view.bounds;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    [vc show];
    currentViewController = vc;
}

#pragma mark - User Actions

- (void)handleLongTap:(UITapGestureRecognizer *)sender
{
    DDLogDebug(@"Handling Long Tap");

    //    [oldVC willMoveToParentViewController:nil];
    //    [self addChildViewController:newVC];
    //
    //    // Get the start frame of the new view controller and the end frame
    //    // for the old view controller. Both rectangles are offscreen.
    //    newVC.view.frame = [self newViewStartFrame];
    //    CGRect endFrame = [self oldViewEndFrame];
    //
    //    UIViewControllerAnimatedTransitioning
    //
    //    // Queue up the transition animation.
    //    [self transitionFromViewController: oldVC toViewController: newVC
    //                              duration: 0.25 options:0
    //                            animations:^{
    //                                // Animate the views to their final positions.
    //                                newVC.view.frame = oldVC.view.frame;
    //                                oldVC.view.frame = endFrame;
    //                            }
    //                            completion:^(BOOL finished) {
    //                                // Remove the old view controller and send the final
    //                                // notification to the new view controller.
    //                                [oldVC removeFromParentViewController];
    //                                [newVC didMoveToParentViewController:self];
    //                            }];

    [self hideViewController:teaserViewController];
    [self showViewController:unlockedViewController];
}

- (void)handleLockTap:(UIButton *)sender
{
    DDLogDebug(@"Handling Lock Tap");

    [self hideViewController:unlockedViewController];
    [self showViewController:teaserViewController];
}

#pragma mark - Displayable Protocol

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    [currentViewController hideAndMoveToViewController:viewController];
}

- (void)show
{
    [currentViewController show];
}

- (void)redisplay
{
    [currentViewController redisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
