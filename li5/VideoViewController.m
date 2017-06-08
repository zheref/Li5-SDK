//
//  VideoViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import Li5Api;

#import "TeaserViewController.h"
#import "UnlockedViewController.h"
#import "VideoViewController.h"
#import "Li5SDK/Li5SDK-Swift.h"

@interface VideoViewController ()
{
    TeaserViewController *teaserViewController;
    UnlockedViewController *unlockedViewController;
    UIViewController<DisplayableProtocol> *currentViewController;
}

@end

@implementation VideoViewController

@synthesize product;

- (id)initWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx
{
    self = [super init];
    if (self)
    {
        DDLogVerbose(@"");
        self.product = thisProduct;
        teaserViewController = [TeaserViewController teaserWithProduct:self.product andContext:ctx];
//        if (self.product.videoURL != nil && self.product.videoURL.length > 0)
//        {
//            unlockedViewController = [UnlockedViewController unlockedWithProduct:self.product andContext:ctx];
//        }
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
    [self.view setBackgroundColor: [UIColor redColor]];
    
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
    return YES;
}

- (void)hideViewController:(UIViewController<DisplayableProtocol> *)vc withAppearanceTransition:(BOOL)appear force:(BOOL)force
{
    DDLogVerbose(@"");
    [vc willMoveToParentViewController:nil];
    if (appear) [vc beginAppearanceTransition:NO animated:NO];
    if (force) [vc.view removeFromSuperview]; else [vc.view setAlpha:0.5];
    if (appear) [vc endAppearanceTransition];
    if (force) [vc removeFromParentViewController];
    [vc didMoveToParentViewController:nil];
}

- (void)showViewController:(UIViewController<DisplayableProtocol> *)vc withAppearanceTransition:(BOOL)appear
{
    DDLogVerbose(@"");
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    vc.view.frame = self.view.bounds;
    [vc.view setAlpha:1.0];
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
    unlockedViewController.initialPoint = [sender locationInView:teaserViewController.view];
    
    unlockedViewController.providesPresentationContextTransitionStyle = true;
    unlockedViewController.definesPresentationContext = true;
    unlockedViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [self showViewController:unlockedViewController withAppearanceTransition:YES];
    [self hideViewController:teaserViewController withAppearanceTransition:YES force:NO];
}

- (void)handleLockTap:(UIGestureRecognizer *)recognizer
{
    DDLogVerbose(@"Handling Lock Tap");
    
    [self hideViewController:unlockedViewController withAppearanceTransition:YES force:YES];
    [self showViewController:teaserViewController withAppearanceTransition:YES];
}

-(BCPlayer *)getPlayer {
    
    return [teaserViewController getPlayer];
}

#pragma mark - iOS Actions


//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    
//    teaserViewController.view.frame = self.view.bounds;
//    //    self.posterImageView.frame = self.view.bounds;
//}

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
