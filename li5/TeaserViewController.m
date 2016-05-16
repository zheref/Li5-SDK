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

#pragma mark - Class Definitions

@interface TeaserViewController ()
{
    ProductContext pContext;
    id mTeaserRemainingObserver;
    id playEndObserver;
    CAShapeLayer *progressLayer;
    CATextLayer *timeText;
    NSMutableArray<CALayer *> *removableItems;
    
    UIPanGestureRecognizer *profilePanGestureRecognizer;
    UIPanGestureRecognizer *searchPanGestureRecognizer;
    UIPanGestureRecognizer *backToSearchPanGestureRecognzier;
    UILongPressGestureRecognizer *longTapGestureRecognizer;
    id<UserProfileViewControllerPanTargetDelegate> profileInteractor;
    id<ProductsViewControllerPanTargetDelegate> searchInteractor;
}

@property (nonatomic, weak) AVPlayerLayer *teaserPlayer;

@end

@implementation TeaserViewController

@synthesize product, previousViewController, nextViewController;

- (id)initWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx
{
    self = [super init];
    if (self)
    {
        DDLogVerbose(@"Initializing TeaserViewController for: %@", thisProduct.id);
        self.product = thisProduct;
        pContext = ctx;
        [self teaserPlayer];

        removableItems = [NSMutableArray<CALayer *> array];
    }
    return self;
}

#pragma mark - UI View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DDLogVerbose(@"Loading TeaserViewController for: %@", self.product.id);

    [self.view setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(20/255.0) blue:(147/255.0) alpha:1]];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.tag = 19;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    [self setupGestureRecognizers];

    [self.view.layer addSublayer:self.teaserPlayer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogDebug(@"");
    [super viewDidDisappear:animated];
    
    [((BCPlayer*)self.teaserPlayer.player) pause];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogDebug(@"");
    [super viewDidAppear:animated];
    
    [self show];
}

#pragma mark - Players

- (AVPlayerLayer *)teaserPlayer
{
    if (_teaserPlayer == nil)
    {
        NSURL *playerUrl = [NSURL URLWithString:self.product.trailerURL];
        DDLogVerbose(@"Creating Teaser Video Player Layer for: %@", [playerUrl lastPathComponent]);
        BCPlayer *player = [[BCPlayer alloc] initWithPlayListUrl:playerUrl bufferInSeconds:20.0 priority:BCPriorityHigth delegate:self];
        //AVPlayer *player = [[AVPlayer alloc] initWithURL:playerUrl];

        _teaserPlayer = [AVPlayerLayer playerLayerWithPlayer:player];
        _teaserPlayer.frame = self.view.bounds;
        _teaserPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }

    return _teaserPlayer;
}

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

#pragma mark - Displayable Protocol

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    float secondsWatched = CMTimeGetSeconds(self.teaserPlayer.player.currentTime);
    DDLogVerbose(@"User saw %@ during %f", self.product.id, secondsWatched);
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 postUserWatchedVideoWithID:self.product.id withType:Li5VideoTypeTrailer during:[NSNumber numberWithFloat:secondsWatched] inContext:Li5ContextDiscover withCompletion:^(NSError *error) {
      if (error)
      {
          DDLogError(@"%@", error.localizedDescription);
      }
    }];

    [((BCPlayer*)self.teaserPlayer.player) pauseAndDestroy];
    
    [self prepareForRemoval];
}

- (void)show
{
    if (
        self.teaserPlayer.player.status == AVPlayerStatusReadyToPlay //Player is ready to Play
        && self.parentViewController.parentViewController != nil //Teaser is contained within a ProductPageViewController
        && self.parentViewController.parentViewController == [((UIPageViewController *)self.parentViewController.parentViewController.parentViewController).viewControllers firstObject] //ProductPageViewController is currently being viewed at PrimeTime
        && self.parentViewController == [((ProductPageViewController *)self.parentViewController.parentViewController) currentViewController] //Video is being watched
        )
    {
        DDLogVerbose(@"Show %@.", [[(AVURLAsset *)self.teaserPlayer.player.currentItem.asset URL] lastPathComponent]);
        
        [self.teaserPlayer.player play];
        
        [self renderAnimations];
        [self setupObservers];
    }
}

- (void)redisplay
{
    [self.teaserPlayer.player seekToTime:kCMTimeZero];
    [self.teaserPlayer.player play];
}

- (void)prepareForRemoval
{
    if (playEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:playEndObserver];
        playEndObserver = nil;
    }
    if (mTeaserRemainingObserver)
    {
        [_teaserPlayer.player removeTimeObserver:mTeaserRemainingObserver];
        [mTeaserRemainingObserver invalidate];
        mTeaserRemainingObserver = nil;
    }
}

- (void)setupObservers
{
    if (!mTeaserRemainingObserver)
    {
        __weak typeof(self) weakSelf = self;
        mTeaserRemainingObserver = [self.teaserPlayer.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                                                          queue:NULL /* If you pass NULL, the main queue is used. */
                                                                                     usingBlock:^(CMTime time) {
                                                                                         [weakSelf updateProgressTimerWithSecondsPlayed:CMTimeGetSeconds(time)];
                                                                                     }];
    }
    
    if (!playEndObserver)
    {
        __weak typeof(id) welf = self;
        playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.teaserPlayer.player.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf replayMovie:note];
        }];
    }
}

#pragma mark - User Actions

- (void)userDidPan:(UIPanGestureRecognizer*)gestureRecognizer
{
    [((BCPlayer*)self.teaserPlayer.player) pause];
    [searchInteractor userDidPan:gestureRecognizer];
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

- (void)shareProduct:(UIButton *)button
{
    DDLogVerbose(@"Share Button Pressed");
    NSString *textToShare = @"Look at this awesome product!";
    NSURL *productURL = [NSURL URLWithString:[[[[Li5ApiHandler sharedInstance] baseURL] stringByAppendingPathComponent:@"p"] stringByAppendingPathComponent:self.product.id]];

    NSArray *objectsToShare = @[ textToShare, productURL ];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

    NSArray *excludeActivities = @[ UIActivityTypePostToWeibo,
                                    UIActivityTypePrint,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToTencentWeibo,
                                    UIActivityTypeAirDrop ];

    activityVC.excludedActivityTypes = excludeActivities;

    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)loveProduct:(UIButton *)button
{
    DDLogVerbose(@"Love Button Pressed");
    __weak typeof(self) welf = self;
    if (button.selected)
    {
        welf.product.is_loved = false;
        [button setSelected:false];
        [[Li5ApiHandler sharedInstance] deleteLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
          if (error != nil)
          {
              welf.product.is_loved = true;
              [button setSelected:true];
          }
        }];
    }
    else
    {
        welf.product.is_loved = true;
        [button setSelected:true];
        [[Li5ApiHandler sharedInstance] postLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
          if (error != nil)
          {
              welf.product.is_loved = false;
              [button setSelected:false];
          }
        }];
    }
}

- (void)goBackToSearch:(UIPanGestureRecognizer *)recognizer
{
    [self hideAndMoveToViewController:nil];
    [searchInteractor userDidPan:nil];
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers
{
    //Unlock Video Long Tap Gesture Recognizer - Tap & Hold
    if (product.videoURL != nil && ![product.videoURL isEqualToString:@""])
    {
        longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        longTapGestureRecognizer.minimumPressDuration = 1.0f;
        longTapGestureRecognizer.allowableMovement = 100.0f;
        
        [self.view addGestureRecognizer:longTapGestureRecognizer];
    }
    
    //User Profile Gesture Recognizer - Swipe Down from 0-100px
    profileInteractor = [[UserProfileDynamicInteractor alloc] initWithParentViewController:self];
    profilePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:profileInteractor action:@selector(userDidPan:)];
    [profilePanGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:profilePanGestureRecognizer];
    
    searchInteractor = [[ProductsListDynamicInteractor alloc] initWithParentViewController:self];
    if (pContext != kProductContextSearch)
    {
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
    else if (gestureRecognizer == searchPanGestureRecognizer || gestureRecognizer == backToSearchPanGestureRecognzier)
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
            (otherGestureRecognizer == searchPanGestureRecognizer || otherGestureRecognizer == backToSearchPanGestureRecognzier));
}

#pragma mark - Animations

- (void)removeAnimations
{
    if ([removableItems count] > 0)
    {
        DDLogVerbose(@"removing animations");
        [removableItems makeObjectsPerformSelector:@selector(removeAllAnimations)];
        [removableItems makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [removableItems removeAllObjects];
        progressLayer = nil;
        timeText = nil;
        [self.view setNeedsDisplay];
    }
}

- (void)renderAnimations
{
    [self removeAnimations];
    DDLogVerbose(@"rendering animations");
    
    [self renderCategory];

    UIButton *loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loveBtn setImage:[UIImage imageNamed:@"Love"] forState:UIControlStateNormal];
    [loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateHighlighted];
    [loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateSelected];
    [loveBtn setFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 180, 30, 30)];
    [loveBtn addTarget:self action:@selector(loveProduct:) forControlEvents:UIControlEventTouchUpInside];
    [loveBtn setSelected:self.product.is_loved];
    [self.view addSubview:loveBtn];

    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
    [shareBtn setImage:[UIImage imageNamed:@"ShareSelected"] forState:UIControlStateHighlighted];
    [shareBtn setFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 130, 30, 30)];
    [shareBtn addTarget:self action:@selector(shareProduct:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];

    //Triangle up selection
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(0, 10)];
    [trianglePath addLineToPoint:CGPointMake(5, 5)];
    [trianglePath addLineToPoint:CGPointMake(10, 10)];
    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
    [triangleMaskLayer setPath:trianglePath.CGPath];
    [triangleMaskLayer setBorderColor:[[UIColor whiteColor] CGColor]];
    [triangleMaskLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [triangleMaskLayer setFillColor:[[UIColor clearColor] CGColor]];
    CGPoint triangleMaskLayerPosition = CGPointMake(self.view.frame.size.width / 2 - 5, self.view.frame.size.height - 35);
    [triangleMaskLayer setPosition:triangleMaskLayerPosition];

    [self.view.layer addSublayer:triangleMaskLayer];
    [removableItems addObject:triangleMaskLayer];

    CABasicAnimation *moveUpAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveUpAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    moveUpAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width / 2 - 5, self.view.frame.size.height + 50)];
    moveUpAnimation.toValue = [NSValue valueWithCGPoint:triangleMaskLayerPosition];
    moveUpAnimation.duration = 1.0f;

    [triangleMaskLayer addAnimation:moveUpAnimation forKey:@"position"];

    //Read More text
    CATextLayer *readMore = [CATextLayer layer];
    readMore.frame = CGRectMake(0, self.view.frame.size.height - 20, self.view.frame.size.width, 20);
    readMore.contentsGravity = kCAGravityCenter;
    readMore.alignmentMode = kCAAlignmentCenter;
    readMore.string = @"MORE";
    readMore.font = (__bridge CFTypeRef)([UIFont systemFontOfSize:12.0]);
    readMore.fontSize = 12.0;
    readMore.foregroundColor = (__bridge CGColorRef)([UIColor whiteColor]);
    readMore.contentsScale = [UIScreen mainScreen].scale;

    [self.view.layer addSublayer:readMore];
    [removableItems addObject:readMore];

    moveUpAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height + 30)];
    moveUpAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 10)];

    [readMore addAnimation:moveUpAnimation forKey:@"position"];
}

//- (void)renderBackButton
//{
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backBtn setTitle:@"<" forState:UIControlStateNormal];
//    [backBtn setFrame:CGRectMake(10, 10, 30, 30)];
//    [backBtn addTarget:self action:@selector(goBackToSearch:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBtn];
//}

- (void)renderCategory
{
    UIFont *categoryFont = [UIFont fontWithName:@"Avenir-Black" size:15.0];
    NSString *category = self.product.categoryName;
    CGRect categorySize = [category boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : categoryFont } context:nil];
    
    CAShapeLayer *categoryLayer = [CAShapeLayer layer];
    UIBezierPath *hexagonPath = [ShapesHelper hexagonWithWidth:categorySize.size.width andHeight:categorySize.size.height + 24];
    hexagonPath.lineJoinStyle = kCGLineJoinRound;
    hexagonPath.lineCapStyle = kCGLineCapRound;
    [categoryLayer setPath:[hexagonPath CGPath]];
    [categoryLayer setFrame:CGRectMake(25, 17, hexagonPath.bounds.size.width, hexagonPath.bounds.size.height)];
    [categoryLayer setFillColor:[[UIColor blackColor] CGColor]];
    [categoryLayer setLineCap:kCALineCapRound];
    [categoryLayer setLineJoin:kCALineJoinRound];
    
    CATextLayer *categoryText = [CATextLayer layer];
    categoryText.frame = CGRectMake(0, 12, hexagonPath.bounds.size.width, hexagonPath.bounds.size.height);
    categoryText.string = category;
    categoryText.font = (__bridge CFTypeRef)categoryFont;
    categoryText.fontSize = 15.0;
    categoryText.foregroundColor = (__bridge CGColorRef)([UIColor whiteColor]);
    categoryText.alignmentMode = kCAAlignmentCenter;
    categoryText.contentsGravity = kCAGravityCenter;
    categoryText.contentsScale = [UIScreen mainScreen].scale;
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    [lineLayer setPath:[[ShapesHelper rectangleWithWidth:15 andHeight:2] CGPath]];
    [lineLayer setFillColor:[[UIColor blackColor] CGColor]];
    [lineLayer setPosition:CGPointMake(0, categoryLayer.position.y)];
    
    CABasicAnimation *extendToRight = [CABasicAnimation animationWithKeyPath:@"path"];
    extendToRight.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    extendToRight.fromValue = (__bridge id _Nullable)([[ShapesHelper rectangleWithWidth:15 andHeight:2] CGPath]);
    extendToRight.toValue = (__bridge id _Nullable)([[ShapesHelper rectangleWithWidth:self.view.frame.size.width andHeight:2] CGPath]);
    extendToRight.duration = 1.0f;
    [lineLayer addAnimation:extendToRight forKey:@"extendToRight"];
    
    CABasicAnimation *extendToLeft = [CABasicAnimation animationWithKeyPath:@"path"];
    extendToLeft.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    extendToLeft.fromValue = (__bridge id _Nullable)([[ShapesHelper rectangleWithWidth:self.view.frame.size.width andHeight:2] CGPath]);
    extendToLeft.toValue = (__bridge id _Nullable)([[ShapesHelper rectangleWithWidth:15 andHeight:2] CGPath]);
    extendToLeft.duration = 1.0f;
    extendToLeft.beginTime = CACurrentMediaTime() + 1.0;
    [lineLayer addAnimation:extendToLeft forKey:@"extendToLeft"];
    
    [self.view.layer addSublayer:lineLayer];
    [self.view.layer addSublayer:categoryLayer];
    [categoryLayer addSublayer:categoryText];
    
    [removableItems addObject:lineLayer];
    [removableItems addObject:categoryLayer];
}

- (void)updateProgressTimerWithSecondsPlayed:(CGFloat)timePlayed
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];

    CGFloat startAngle = M_PI * 1.5;
    CGFloat endAngle = startAngle + (M_PI * 2);

    double remainingTime = CMTimeGetSeconds(self.teaserPlayer.player.currentItem.asset.duration) - timePlayed;
    double percentage = remainingTime / CMTimeGetSeconds(self.teaserPlayer.player.currentItem.asset.duration);

    CGPoint progressCenter = CGPointMake(self.view.frame.size.width - 30, 38);

    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:progressCenter
                          radius:17
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * percentage + startAngle
                       clockwise:NO];

    if (progressLayer == nil)
    {
        progressLayer = [CAShapeLayer layer];
        [progressLayer setFillColor:[UIColor clearColor].CGColor];
        [progressLayer setStrokeColor:[UIColor whiteColor].CGColor];
        [progressLayer setLineWidth:3.0];
        [progressLayer setLineCap:kCALineCapRound];
        [progressLayer setZPosition:100];
        [self.view.layer addSublayer:progressLayer];
        [removableItems addObject:progressLayer];

        CAShapeLayer *timerLayer = [CAShapeLayer layer];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:progressCenter radius:16 startAngle:startAngle endAngle:endAngle clockwise:YES];
        [timerLayer setFillColor:[UIColor blackColor].CGColor];
        [timerLayer setPath:[circlePath CGPath]];
        [timerLayer setZPosition:101];
        [self.view.layer addSublayer:timerLayer];
        [removableItems addObject:timerLayer];

        UIFont *timeFont = [UIFont fontWithName:@"Avenir" size:12.0];
        timeText = [CATextLayer layer];
        timeText.frame = CGRectMake(progressCenter.x - 10, progressCenter.y - 8, 20, 20);
        //timeText.string = [NSString stringWithFormat:@"%f",percentage];
        timeText.font = (__bridge CFTypeRef)timeFont;
        timeText.fontSize = 12.0;
        timeText.foregroundColor = (__bridge CGColorRef)([UIColor whiteColor]);
        timeText.alignmentMode = kCAAlignmentCenter;
        timeText.contentsGravity = kCAGravityCenter;
        timeText.contentsScale = [UIScreen mainScreen].scale;
        [timeText setZPosition:102];
        [timerLayer addSublayer:timeText];
        [removableItems addObject:timeText];
    }

    CABasicAnimation *animateStrokEnd = [CABasicAnimation animationWithKeyPath:@"path"];
    animateStrokEnd.duration = 1;
    animateStrokEnd.fromValue = (id)progressLayer.path;
    animateStrokEnd.toValue = (id)[bezierPath CGPath];
    [progressLayer addAnimation:animateStrokEnd forKey:nil];
    [progressLayer setPath:[bezierPath CGPath]];

    timeText.string = [NSString stringWithFormat:@"%li", (long)remainingTime];
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
    [self prepareForRemoval];
    _teaserPlayer = nil;
}

@end