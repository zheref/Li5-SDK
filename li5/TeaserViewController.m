//
//  ViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import BCVideoPlayer;

#import "ShapesHelper.h"
#import "TeaserViewController.h"
#import "ProductPageViewController.h"
#import "ProductsViewController.h"
#import "UserProfileDynamicInteractor.h"
#import "ProductsListDynamicInteractor.h"
#import "Li5PlayerTimer.h"
#import "ProductPageActionsView.h"

#pragma mark - Class Definitions

@interface TeaserViewController ()
{
    ProductContext pContext;
    id playEndObserver;
    
    UIPanGestureRecognizer *profilePanGestureRecognizer;
    UIPanGestureRecognizer *searchPanGestureRecognizer;
    UIPanGestureRecognizer *backToSearchPanGestureRecognzier;
    UILongPressGestureRecognizer *longTapGestureRecognizer;
    id<UserProfileViewControllerPanTargetDelegate> profileInteractor;
    id<ExploreViewControllerPanTargetDelegate> searchInteractor;
    
    BOOL __hasUnlockedVideo;
}

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (nonatomic, strong) BCPlayer *teaserPlayer;
@property (weak, nonatomic) IBOutlet Li5PlayerTimer *playerTimer;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;
@property (weak, nonatomic) IBOutlet ProductPageActionsView *actionsView;

@end

@implementation TeaserViewController

@synthesize product, previousViewController, nextViewController;

- (id)initWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx
{
    UIStoryboard *productPageStoryboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle mainBundle]];
    self = [productPageStoryboard instantiateViewControllerWithIdentifier:@"TeaserView"];
    if (self)
    {
        DDLogVerbose(@"Initializing TeaserViewController for: %@", thisProduct.id);
        self.product = thisProduct;
        pContext = ctx;
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    __hasUnlockedVideo = (self.product.videoURL != nil && ![self.product.videoURL isEqualToString:@""]);
    
    NSURL *playerUrl = [NSURL URLWithString:self.product.trailerURL];
    _teaserPlayer = [[BCPlayer alloc] initWithUrl:playerUrl bufferInSeconds:20.0 priority:BCPriorityHigh delegate:self];
    //AVPlayer *player = [[AVPlayer alloc] initWithURL:playerUrl];
}

#pragma mark - UI View

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DDLogVerbose(@"Loading TeaserViewController for: %@", self.product.id);

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.tag = 19;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    BCPlayerLayer *playerLayer = [[BCPlayerLayer alloc] initWithPlayer:_teaserPlayer andFrame:self.view.bounds];
    playerLayer.frame = self.view.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.playerView.layer addSublayer:playerLayer];
    
    [self.playerTimer setHasUnlocked:__hasUnlockedVideo];
    [self.actionsView setProduct:self.product];
    
    self.categoryLabel.text = self.product.categoryName;
    self.categoryImage.image = [UIImage imageNamed:[[self.product.categoryName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString]];
    
    self.categoryImage.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    self.categoryImage.layer.shadowOffset = CGSizeMake(0, 2);
    self.categoryImage.layer.shadowOpacity = 1;
    self.categoryImage.layer.shadowRadius = 1.0;
    self.categoryImage.clipsToBounds = NO;
    
    if (pContext != kProductContextDiscover)
    {
        CALayer *contextLayer = [[CALayer alloc] init];
        contextLayer.backgroundColor = [UIColor li5_redColor].CGColor;
        contextLayer.frame = CGRectMake(0,0,self.view.frame.size.width,5);
        [self.view.layer addSublayer:contextLayer];
    }
    
    [self setupGestureRecognizers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogDebug(@"");
    [super viewDidDisappear:animated];
    
    [self.teaserPlayer pause];
    [self removeObservers];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogDebug(@"");
    [super viewDidAppear:animated];
    
    [self show];
}

#pragma mark - Players

- (void)replayMovie:(NSNotification *)notification
{
    DDLogVerbose(@"replaying video");
    [self redisplay];
}

- (void)readyToPlay
{
    DDLogDebug(@"Ready to play trailer for: %lu", (unsigned long)[((ProductPageViewController*)self.parentViewController.parentViewController) index]);
    
    //Stop spinner
    [[self.view viewWithTag:19] stopAnimating];
    
    [self show];
}

- (void)failToLoadItem
{
    DDLogVerbose(@"");
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
}

#pragma mark - Displayable Protocol

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    float secondsWatched = CMTimeGetSeconds(self.teaserPlayer.currentTime);
    DDLogVerbose(@"User saw %@ during %f", self.product.id, secondsWatched);
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 postUserWatchedVideoWithID:self.product.id withType:Li5VideoTypeTrailer during:[NSNumber numberWithFloat:secondsWatched] inContext:Li5ContextDiscover withCompletion:^(NSError *error) {
      if (error)
      {
          DDLogError(@"%@", error.localizedDescription);
      }
    }];

    [self removeObservers];
    [self.teaserPlayer pauseAndDestroy];
}

- (void)show
{
    if (
        self.teaserPlayer.status == AVPlayerStatusReadyToPlay //Player is ready to Play
        && self.parentViewController.parentViewController != nil //Teaser is contained within a ProductPageViewController
        && self.parentViewController.parentViewController == [((UIPageViewController *)self.parentViewController.parentViewController.parentViewController).viewControllers firstObject] //ProductPageViewController is currently being viewed at PrimeTime
        && self.parentViewController == [((ProductPageViewController *)self.parentViewController.parentViewController) currentViewController] //Video is being watched
        )
    {
        DDLogVerbose(@"Show %@.", [[(AVURLAsset *)self.teaserPlayer.currentItem.asset URL] lastPathComponent]);
        
        [self.playerTimer setPlayer:self.teaserPlayer];
        
        [self.teaserPlayer play];
        
        [self renderAnimations];
        [self setupObservers];
    }
}

- (void)redisplay
{
    [self.teaserPlayer seekToTime:kCMTimeZero];
    [self.teaserPlayer play];
}

- (void)removeObservers
{
    if (playEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:playEndObserver];
        playEndObserver = nil;
    }
}

- (void)setupObservers
{
    if (!playEndObserver)
    {
        __weak typeof(id) welf = self;
        playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.teaserPlayer.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf replayMovie:note];
        }];
    }
}

#pragma mark - User Actions

- (void)userDidPan:(UIPanGestureRecognizer*)gestureRecognizer
{
    [self.teaserPlayer pause];
    [searchInteractor userDidPan:gestureRecognizer];
}

- (IBAction)userDidTap:(UITapGestureRecognizer*)sender
{
    if (__hasUnlockedVideo)
    {
        UIViewController *modalView = [self.storyboard instantiateViewControllerWithIdentifier:@"TapAndHoldToUnlockView"];
        modalView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        [self presentViewController:modalView animated:NO completion:^{
            //Nothing for now
        }];
    }
}

- (void)handleLongTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        //Long Tap transparent Background Rectangle
        CGFloat animationDuration = 0.5f;
        CGFloat fromRadius = 50.0f;
        CGFloat toRadius = 800.0f;

        CGPoint touchPosition = [sender locationInView:self.view];

        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(touchPosition.x, touchPosition.y, 100, 100)];
        circleView.alpha = 0.2;
        circleView.center = touchPosition;
        circleView.layer.cornerRadius = fromRadius;
        circleView.backgroundColor = [UIColor blackColor];

        [self.view addSubview:circleView];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:fromRadius];
        animation.toValue = [NSNumber numberWithFloat:toRadius];
        animation.duration = animationDuration;
        animation.fillMode = kCAFillModeBoth;
        circleView.layer.cornerRadius = toRadius;
        [circleView.layer addAnimation:animation forKey:@"cornerRadius"];

        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
          circleView.frame = CGRectMake(-800, -500, 2 * toRadius, 2 * toRadius);
        }
            completion:^(BOOL finished) {
              [circleView removeFromSuperview];
            }];

        [self.parentViewController performSelectorOnMainThread:@selector(handleLongTap:) withObject:sender waitUntilDone:NO];
    }
}

- (void)goBackToSearch:(UIPanGestureRecognizer *)recognizer
{
    //TODO use Search interactor
    [self.navigationController popViewControllerAnimated:NO];
    [self hideAndMoveToViewController:nil];
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers
{
    //Unlock Video Long Tap Gesture Recognizer - Tap & Hold
    if (__hasUnlockedVideo)
    {
        longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        longTapGestureRecognizer.minimumPressDuration = 1.0f;
        longTapGestureRecognizer.allowableMovement = 100.0f;
        
        [self.view addGestureRecognizer:longTapGestureRecognizer];
    }
    
    //User Profile Gesture Recognizer - Swipe Down from 0-100px
    profileInteractor = [[UserProfileDynamicInteractor alloc] initWithParentViewController:self];
    searchInteractor = [[ProductsListDynamicInteractor alloc] initWithParentViewController:self];
    
    if (pContext == kProductContextDiscover)
    {
        //Profile Gesture Recognizer - Swipe Down from 0-100px
        profilePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:profileInteractor action:@selector(userDidPan:)];
        [profilePanGestureRecognizer setDelegate:self];
        [self.view addGestureRecognizer:profilePanGestureRecognizer];
        
        //Search Products Gesture Recognizer - Swipe Down from below 100px
        searchPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
        [searchPanGestureRecognizer setDelegate:self];
        [self.view addGestureRecognizer:searchPanGestureRecognizer];
    }
    else
    {
        backToSearchPanGestureRecognzier = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(goBackToSearch:)];
        backToSearchPanGestureRecognzier.delegate = self;
        [self.view addGestureRecognizer:backToSearchPanGestureRecognzier];
    }
    
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
    else if (gestureRecognizer == backToSearchPanGestureRecognzier)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
        return (fabs(degree) > 20.0) && (velocity.y > 0);
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
            (otherGestureRecognizer == searchPanGestureRecognizer || otherGestureRecognizer == backToSearchPanGestureRecognzier));
}

#pragma mark - Animations

- (void)removeAnimations
{
//    if ([removableItems count] > 0)
//    {
//        DDLogVerbose(@"removing animations");
//        [removableItems makeObjectsPerformSelector:@selector(removeAllAnimations)];
//        [removableItems makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//        [removableItems removeAllObjects];
//        progressLayer = nil;
//        timeText = nil;
//        [self.view setNeedsDisplay];
//    }
}

- (void)renderAnimations
{
    [self removeAnimations];
    DDLogVerbose(@"rendering animations");
    
    [self renderCategory];

}

- (void)renderCategory
{
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DDLogDebug(@"");
    [self removeObservers];
    _teaserPlayer = nil;
}

@end