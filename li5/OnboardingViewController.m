//
//  OnboardingViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/30/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import SMPageControl;
@import AVFoundation;
@import Intercom;

#import "OnboardingViewController.h"
#import "LoginViewController.h"
#import "OnboardingPageContentViewController.h"
#import <objc/runtime.h>
#import "Li5VolumeView.h"
#import "UIBezierPath+UIImage.h"
#import "RightArrowUIView.h"

@interface OnboardingViewController ()

@property (weak, nonatomic) Li5UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet SMPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;

@property (strong, nonatomic) NSArray<NSString*> *pageTitles;
@property (strong, nonatomic) NSArray<NSString*> *pageSubtitles;
@property (strong, nonatomic) NSArray<NSURL*> *pageVideos;

@property (nonatomic, assign) CGPoint originalLogoPosition;
@property (nonatomic, assign) CGPoint lastLogoPosition;

@property (nonatomic, assign) BOOL animationsSetupAlready;

@property (weak, nonatomic) IBOutlet UIButton *rightArrow;

@end

@implementation OnboardingViewController

#pragma mark - UI Setup

- (instancetype)init
{
    self = [super init];
    if (self) {
        //Do nothing since initialize is called by storybaord initWithCoder
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    
    _pageTitles = @[NSLocalizedString(@"Watch Fun Videos",nil),NSLocalizedString(@"Discover",nil)];
    _pageSubtitles = @[NSLocalizedString(@"Made by Creative Sellers",nil),NSLocalizedString(@"Awesome New Products You'll ❤️",nil)];
    _pageVideos = @[
                    [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"onboarding_1" ofType:@"mp4"]],
                    [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"onboarding_2" ofType:@"mp4"]]
                    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Intercom registerUnidentifiedUser];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0,16.0,16.0)];
    circlePath.lineWidth = 2.0;
    UIImage *emptyCircle = [circlePath imageWithStrokeColor:[UIColor li5_whiteColor] fillColor:[UIColor clearColor]];
    UIImage *fullCircle = [circlePath imageWithStrokeColor:[UIColor li5_whiteColor] fillColor:[UIColor whiteColor]];
    
    [_pageControl setPageIndicatorImage:emptyCircle];
    [_pageControl setCurrentPageIndicatorImage:fullCircle];
    
    _pageControl.numberOfPages = 3;
    _pageControl.indicatorMargin = 10.0;
    _pageControl.indicatorDiameter = 16.0;
    _pageControl.tapBehavior = SMPageControlTapBehaviorJump;
    [_pageControl addTarget:self action:@selector(pageUpdated) forControlEvents:UIControlEventValueChanged];
    [_pageControl sizeToFit];
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
    
#if DEBUG
    NSString *target = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    if ([target containsString:@"Test"]) {
        self.logoView.image = [UIImage imageNamed:@"logo_small_test"];
    }
#endif
    
    NSArray *viewControllers = @[[self viewControllerAtIndex:0]];
    [self.pageViewController setViewControllers:viewControllers];
    
    _animationsSetupAlready = false;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = true;
    
    [_pageViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_pageViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_pageViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_pageViewController endAppearanceTransition];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (!_animationsSetupAlready)
    {
        _originalLogoPosition = self.logoView.layer.position;
        
        [self setupAnimations];
        _animationsSetupAlready = true;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return _pageViewController.shouldAutomaticallyForwardAppearanceMethods;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DDLogVerbose(@"");
    if ([[segue identifier] isEqualToString:@"pageViewEmbed"])
    {
        _pageViewController = (Li5UIPageViewController*)[segue destinationViewController];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
        _pageViewController.bounces = NO;
    }
}

- (void)setupAnimations
{
    DDLogVerbose(@"");
    CABasicAnimation *logoPositionAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    logoPositionAnimation.fromValue = @(self.view.center.y);
    logoPositionAnimation.toValue = @(self.logoView.center.y);
    
    CABasicAnimation *logoScaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    logoScaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3.0, 3.0, 1.0)];
    logoScaleAnimation.toValue = [NSValue valueWithCGAffineTransform:self.logoView.transform];
    
    CAAnimationGroup *logoAnimations = [CAAnimationGroup animation];
    logoAnimations.duration = 0.75;
    logoAnimations.fillMode = kCAFillModeForwards;
    logoAnimations.animations = @[logoPositionAnimation, logoScaleAnimation];
    logoAnimations.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.43 :0 :0.82 :0.60];
    
    [self.logoView.layer addAnimation:logoAnimations forKey:@"logoView"];
    
    CAKeyframeAnimation *trans = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    trans.values = @[@(0),@(-5),@(2.0),@(-3),@(0)];
    trans.keyTimes = @[@(0.0),@(0.35),@(0.70),@(0.90),@(1)];
    trans.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :1.8 :1 :1];
    trans.duration = 2.0;
    trans.additive = YES;
    trans.repeatCount = INFINITY;
    trans.beginTime = CACurrentMediaTime() + 2.0;
    trans.removedOnCompletion = NO;
    trans.fillMode = kCAFillModeForwards;
    [self.rightArrow.layer addAnimation:trans forKey:@"bouncing"];
    
}

#pragma mark - PageViewControllerDataSource

- (UIViewController*)viewControllerAtIndex:(NSInteger)index
{
    if (([self.pageTitles count] == 0) || (index == [self.pageTitles count])) {
        
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardingLoginView"];
        [vc setScrollPageIndex:index];
        
        return vc;
    }
    
    if (index > [self.pageTitles count])
    {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    OnboardingPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardingPageContentView"];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.subtitleText = self.pageSubtitles[index];
    pageContentViewController.videoUrl = self.pageVideos[index];
    [pageContentViewController setScrollPageIndex:index];
    
    return pageContentViewController;
}

- (UIViewController *)viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = viewController.scrollPageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = viewController.scrollPageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerViewControllerAtIndex:(NSInteger)index
{
    if ((index < 0) || (index == NSNotFound))
    {
        return nil;
    }
    else
    {
        return [self viewControllerAtIndex:index];
    }
}

#pragma mark - PageViewControllerDelegate

- (void)pageUpdated
{
    [self.pageViewController setVisiblePage:self.pageControl.currentPage];
}

- (void)isSwitchingToPage:(UIViewController*)newPage fromPage:(UIViewController*)oldPage progress:(CGFloat)progress
{
    //DDLogDebug(@"");
    //Progressive animation
//    if (newPage != oldPage)
//    {
//        if (newPage.scrollPageIndex == _pageTitles.count)
//        {
//            CGFloat newScale = 1.0 + 2.0*progress;
//            _lastLogoPosition = ((LoginViewController*)newPage).logoPosition;
//            self.logoView.layer.position = CGPointMake(_lastLogoPosition.x,
//                                                       _originalLogoPosition.y + progress*(_lastLogoPosition.y - _originalLogoPosition.y) );
//            self.logoView.transform = CGAffineTransformMakeScale(newScale, newScale);
////            CATransform3DGetAffineTransform(CATransform3DMakeScale(newScale, newScale, 1.0))
//            
//        }
//        else if (oldPage.scrollPageIndex == _pageTitles.count)
//        {
//            CGFloat newScale = 3.0 - 2.0*progress;
//            self.logoView.layer.position = CGPointMake(_originalLogoPosition.x,
//                                                       _lastLogoPosition.y - progress*(_lastLogoPosition.y - _originalLogoPosition.y) );
//            
//            self.logoView.transform = CGAffineTransformMakeScale(newScale, newScale);
//        }
//    }
}

- (void)didFinishSwitchingPage:(BOOL)finished
{
    DDLogVerbose(@"");
    if (finished)
    {
        NSUInteger index = self.pageViewController.currentViewController.scrollPageIndex;
        self.pageControl.currentPage = index;
        [self.logoView setHighlighted:(index >= _pageTitles.count)];
        
        //Non-progressive animation
        if (index == _pageTitles.count)
        {
            CGFloat newScale = 3.0;
            _lastLogoPosition = ((LoginViewController*)self.pageViewController.currentViewController).logoPosition;
            [UIView animateWithDuration:0.5 animations:^{
                self.logoView.layer.position = CGPointMake(_lastLogoPosition.x,
                                                           _lastLogoPosition.y);
                self.logoView.transform = CGAffineTransformMakeScale(newScale, newScale);
            }];
            self.rightArrow.hidden = YES;
        }
        else
        {
            CGFloat newScale = 1.0;
            [UIView animateWithDuration:0.5 animations:^{
                self.logoView.layer.position = CGPointMake(_originalLogoPosition.x,
                                                           _originalLogoPosition.y);
                self.logoView.transform = CGAffineTransformMakeScale(newScale, newScale);
            }];
            self.rightArrow.hidden = NO;
        }

    }
}

- (IBAction)didTapOnArrow:(id)sender {
    self.pageControl.currentPage++;
    [self pageUpdated];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
