//
//  VideoViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

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

- (id)initWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx
{
    self = [super init];
    if (self)
    {
        DDLogVerbose(@"");
        self.product = thisProduct;
        teaserViewController = [TeaserViewController teaserWithProduct:self.product andContext:ctx];
        if (self.product.videoURL != nil && self.product.videoURL.length > 0)
        {
            unlockedViewController = [UnlockedViewController unlockedWithProduct:self.product andContext:ctx];
        }
        currentViewController = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self showViewController:teaserViewController withAppearanceTransition:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewWillAppear:animated];
    
    [currentViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    [currentViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewWillDisappear:animated];
    
    [currentViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    DDLogVerbose(@"");
    
    [currentViewController endAppearanceTransition];
}

// From the container view controller
- (BOOL) shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)hideViewController:(UIViewController<DisplayableProtocol> *)vc withAppearanceTransition:(BOOL)appear
{
    DDLogVerbose(@"");
    [vc willMoveToParentViewController:nil];
    if (appear) [vc beginAppearanceTransition:NO animated:NO];
    [vc.view removeFromSuperview];
    if (appear) [vc endAppearanceTransition];
    [vc removeFromParentViewController];
    [vc didMoveToParentViewController:nil];
}

- (void)showViewController:(UIViewController<DisplayableProtocol> *)vc withAppearanceTransition:(BOOL)appear
{
    DDLogVerbose(@"");
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    vc.view.frame = self.view.bounds;
    if (appear) [vc beginAppearanceTransition:YES animated:NO];
    [self.view addSubview:vc.view];
    if (appear) [vc endAppearanceTransition];
    [vc didMoveToParentViewController:self];
    currentViewController = vc;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - User Actions

- (void)setPriority:(BCPriority)priority
{
    [teaserViewController setPriority:priority];
}

- (void)handleLongTap:(UITapGestureRecognizer *)sender
{
    DDLogVerbose(@"");

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

    [self hideViewController:teaserViewController withAppearanceTransition:YES];
    [self showViewController:unlockedViewController withAppearanceTransition:YES];
}

- (void)handleLockTap:(UIGestureRecognizer *)recognizer
{
    DDLogVerbose(@"Handling Lock Tap");

    [self hideViewController:unlockedViewController withAppearanceTransition:YES];
    [self showViewController:teaserViewController withAppearanceTransition:YES];
}

#pragma mark - iOS Actions

-(void)dealloc
{
    DDLogDebug(@"%p",self);
    teaserViewController = nil;
    unlockedViewController = nil;
    currentViewController = nil;
}

- (void)didReceiveMemoryWarning
{
    DDLogDebug(@"");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
