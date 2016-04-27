//
//  ViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5PlayerUISlider.h"
#import "ProductPageViewController.h"
#import "RootViewController.h"
#import "ShapesHelper.h"
#import "TeaserViewController.h"
#import "PrimeTimeViewController.h"

#pragma mark - Class Definitions

@interface TeaserViewController ()
{
    id mTeaserRemainingObserver;
    id playEndObserver;
    CAShapeLayer *progressLayer;
    CATextLayer *timeText;
    NSMutableArray<CALayer *> *removableItems;
}

@property (nonatomic, strong) AVPlayerLayer *teaserPlayer;

@end

@implementation TeaserViewController

@synthesize product, previousViewController, nextViewController;

- (id)initWithProduct:(Product *)thisProduct
{
    self = [super init];
    if (self)
    {
        DDLogVerbose(@"Initializing TeaserViewController for: %@", thisProduct.id);
        self.product = thisProduct;

        [self playerLayerForTeaser];
        
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

    [self.view setBackgroundColor:[UIColor greenColor]];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.tag = 19;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    if (product.videoURL != nil && ![product.videoURL isEqualToString:@""])
    {
        UILongPressGestureRecognizer *longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        longTapGestureRecognizer.minimumPressDuration = 1.0f;
        longTapGestureRecognizer.allowableMovement = 100.0f;

        [self.view addGestureRecognizer:longTapGestureRecognizer];
    }

    [self.view.layer addSublayer:self.teaserPlayer];
}

#pragma mark - Players

- (AVPlayerLayer *)playerLayerForTeaser
{
    if (self.teaserPlayer == nil)
    {
        NSURL *playerUrl = [NSURL URLWithString:self.product.trailerURL];
        DDLogVerbose(@"Creating Teaser Video Player Layer for: %@", [playerUrl lastPathComponent]);
        Li5Player *player = [[Li5Player alloc] initWithItemAtURL:playerUrl];
        player.delegate = self;

        self.teaserPlayer = [AVPlayerLayer playerLayerWithPlayer:player];
        //[self.teaserPlayer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
        self.teaserPlayer.frame = self.view.bounds;
        self.teaserPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }

    return self.teaserPlayer;
}

- (void)replayMovie:(NSNotification *)notification
{
    DDLogVerbose(@"replaying video");
    [self redisplay];
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

    [self.teaserPlayer.player pause];
    if (playEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:playEndObserver];
        playEndObserver = nil;
    }
}

- (void)show
{
    if (self.teaserPlayer.player.status == AVPlayerStatusReadyToPlay &&
        self.parentViewController.parentViewController !=nil &&
        self.parentViewController.parentViewController == [((PrimeTimeViewController*)self.parentViewController.parentViewController.parentViewController).viewControllers firstObject])
    {
        DDLogVerbose(@"Show %@.", [[(AVURLAsset *)self.teaserPlayer.player.currentItem.asset URL] lastPathComponent]);
        [self.teaserPlayer.player play];
    }

}

- (void)redisplay
{
    [self.teaserPlayer.player seekToTime:kCMTimeZero];
    //[self.teaserPlayer.player play];
}

#pragma mark - User Actions

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
    if (button.selected)
    {
        [button setSelected:false];
        [[Li5ApiHandler sharedInstance] deleteLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
          if (error != nil)
          {
              [button setSelected:true];
          }
        }];
    }
    else
    {
        [button setSelected:true];
        [[Li5ApiHandler sharedInstance] postLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
          if (error != nil)
          {
              [button setSelected:false];
          }
        }];
    }
}

#pragma mark - Li5PlayerDelegate

- (void)li5Player:(Li5Player *)li5Player changedStatusForPlayerItem:(AVPlayerItem *)playerItem withStatus:(AVPlayerItemStatus)status
{
    if (status == AVPlayerStatusReadyToPlay)
    {
        DDLogVerbose(@"Ready to play for: %@", [[(AVURLAsset *)self.teaserPlayer.player.currentItem.asset URL] lastPathComponent]);

        //Stop spinner
        [[self.view viewWithTag:19] stopAnimating];

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
            playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.teaserPlayer.player queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
                [welf replayMovie:note];
            }];
        }
        
        [self renderAnimations];

        [self show];
    }
}

- (void)li5Player:(Li5Player *)li5Player updatedLoadedSecondsForPlayerItem:(AVPlayerItem *)playerItem withSeconds:(CGFloat)seconds
{
    //DDLogVerbose(@"%@ Loaded %f seconds of %f", [[(AVURLAsset *)playerItem.asset URL] lastPathComponent], seconds, CMTimeGetSeconds(playerItem.duration));
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
    extendToRight.delegate = self;
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

    UIButton *loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loveBtn setImage:[UIImage imageNamed:@"Love"] forState:UIControlStateNormal];
    [loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateHighlighted];
    [loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateSelected];
    [loveBtn setFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 180, 30, 30)];
    [loveBtn addTarget:self action:@selector(loveProduct:) forControlEvents:UIControlEventTouchUpInside];
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
    if (playEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:playEndObserver];
        playEndObserver = nil;
    }
    if (mTeaserRemainingObserver)
    {
        [self.teaserPlayer.player removeTimeObserver:mTeaserRemainingObserver];
        mTeaserRemainingObserver = nil;
    }
    if (self.teaserPlayer != nil)
    {
        //[self.teaserPlayer removeObserver:self forKeyPath:@"readyForDisplay"];
        self.teaserPlayer = nil;
    }
}

@end