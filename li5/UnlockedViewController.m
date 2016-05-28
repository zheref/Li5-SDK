//
//  UnlockedViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "Li5PlayerUISlider.h"
#import "PrimeTimeViewController.h"
#import "UnlockedViewController.h"
#import "ProductPageViewController.h"

static const CGFloat sliderHeight = 50.0;

@interface UnlockedViewController ()
{
    NSTimer *hideControlsTimer;

    UIPanGestureRecognizer *_lockPanGestureRecognzier;
    
    Li5PlayerUISlider *seekSlider;
    UIButton *loveBtn;
    UIButton *shareBtn;
    
    BOOL controlsDisplayed;
}

@property (nonatomic, weak) AVPlayerLayer *extendedVideo;

- (void)removeAnimations;

@end

@implementation UnlockedViewController

@synthesize product;

- (id)initWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx
{
    self = [super init];
    if (self)
    {
        self.product = thisProduct;
        [self extendedVideo];
        
        controlsDisplayed = NO;
    }
    return self;
}

#pragma mark - UI View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];

    [self.view.layer addSublayer:self.extendedVideo];

    [self setupGestureRecognizers];
    
    [self renderAnimations];
    
    [self updateConstraints];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
    
    [((BCPlayer*)self.extendedVideo.player) pause];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    [self show];
}

- (void)renderAnimations
{
    DDLogVerbose(@"rendering animations for unlocked video");
    if (!seekSlider)
    {
        seekSlider = [[Li5PlayerUISlider alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,sliderHeight)];
    }
    
    if (!loveBtn)
    {
        loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [loveBtn setImage:[UIImage imageNamed:@"Love"] forState:UIControlStateNormal];
        [loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateHighlighted];
        [loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateSelected];
        [loveBtn setFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 180, 30, 30)];
        [loveBtn addTarget:self action:@selector(loveProduct:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!shareBtn)
    {
        shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareBtn setImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
        [shareBtn setImage:[UIImage imageNamed:@"ShareSelected"] forState:UIControlStateHighlighted];
        [shareBtn setFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 130, 30, 30)];
        [shareBtn addTarget:self action:@selector(shareProduct:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!controlsDisplayed)
    {
        [loveBtn setSelected:self.product.is_loved];
        
        [self.view addSubview:seekSlider];
        [self.view addSubview:loveBtn];
        [self.view addSubview:shareBtn];
        
        controlsDisplayed = YES;
    }
}

- (void)removeAnimations
{
    DDLogDebug(@"");
    [seekSlider removeFromSuperview];
    [loveBtn removeFromSuperview];
    [shareBtn removeFromSuperview];
    
    [self.view setNeedsDisplay];
    controlsDisplayed = NO;
    
    [self removeObservers];
}

- (void)updateConstraints
{
//    [seekSlider makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view);
//        make.left.equalTo(self.view);
//        make.right.equalTo(self.view);
//        make.height.equalTo(@(sliderHeight));
//    }];
}

#pragma mark - Player

- (AVPlayerLayer *)extendedVideo
{
    if (_extendedVideo == nil)
    {
        NSURL *videoUrl = [NSURL URLWithString:self.product.videoURL];
        DDLogVerbose(@"Creating Full Video Player Layer for: %@", [videoUrl lastPathComponent]);
        BCPlayer *player = [[BCPlayer alloc] initWithPlayListUrl:videoUrl bufferInSeconds:20.0 priority:BCPriorityNormal delegate:self];

        _extendedVideo = [AVPlayerLayer playerLayerWithPlayer:player];
        _extendedVideo.frame = self.view.bounds;
        _extendedVideo.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }

    return _extendedVideo;
}

- (void)readyToPlay
{
    DDLogDebug(@"Ready to play extended for: %lu", (unsigned long)[((ProductPageViewController*)self.parentViewController.parentViewController) index]);
    
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

#pragma mark - User Actions

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

#pragma mark - Displayable Protocol

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    float secondsWatched = CMTimeGetSeconds(self.extendedVideo.player.currentTime);
    DDLogVerbose(@"User saw %@ during %f", self.product.id, secondsWatched);
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 postUserWatchedVideoWithID:self.product.id withType:Li5VideoTypeFull during:[NSNumber numberWithFloat:secondsWatched] inContext:Li5ContextDiscover withCompletion:^(NSError *error) {
      if (error)
      {
          DDLogError(@"%@", error.localizedDescription);
      }
    }];

    [((BCPlayer*)self.extendedVideo.player) pauseAndDestroy];
    
    [self removeObservers];
}

- (void)show
{
    if (self.extendedVideo.player.status == AVPlayerStatusReadyToPlay &&
        self.parentViewController.parentViewController != nil &&
        self.parentViewController.parentViewController == [((PrimeTimeViewController *)self.parentViewController.parentViewController.parentViewController).viewControllers firstObject])
    {
        DDLogVerbose(@"Show %@.", [[(AVURLAsset *)self.extendedVideo.player.currentItem.asset URL] lastPathComponent]);

        [seekSlider setPlayer:self.extendedVideo.player];
        [self.extendedVideo.player play];
        
        [self renderAnimations];
        [self setupObservers];
    }
}

- (void)setupObservers
{
    hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeAnimations) userInfo:nil repeats:NO];
}

- (void)removeObservers
{
    if (hideControlsTimer)
    {
        if ([hideControlsTimer isValid])
        {
            [hideControlsTimer invalidate];
        }
        hideControlsTimer = nil;
    }
}

#pragma mark - Gesture Recognizers

- (void)handleLockTap:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint distance = [(UIPanGestureRecognizer*)recognizer translationInView:recognizer.view];
        if (distance.y > 15)
        {
            [self.parentViewController performSelectorOnMainThread:@selector(handleLockTap:) withObject:recognizer waitUntilDone:NO];
        }
    }
}

- (void)handleSimpleTap:(UIGestureRecognizer *)sender
{
    DDLogVerbose(@"");
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (!controlsDisplayed)
        {
            [self renderAnimations];
            [self setupObservers];
        }
        else
        {
            [self removeAnimations];
        }
    }
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *simpleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSimpleTap:)];
    [self.view addGestureRecognizer:simpleTapGestureRecognizer];
    
    _lockPanGestureRecognzier = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLockTap:)];
    _lockPanGestureRecognzier.delegate = self;
    _lockPanGestureRecognzier.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:_lockPanGestureRecognzier];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touch = [gestureRecognizer locationInView:self.view];
    if (gestureRecognizer == _lockPanGestureRecognzier)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
        return (touch.y >= sliderHeight) && (fabs(degree) > 20.0) && (velocity.y > 0);
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if([[gestureRecognizer view] isKindOfClass:[UIScrollView class]])
    {
        if (otherGestureRecognizer == _lockPanGestureRecognzier)
        {
            return YES;
        }
    }
    return NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removeObservers];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setupObservers];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setupObservers];
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark - Device Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DDLogDebug(@"");
    [self removeObservers];
    _extendedVideo = nil;
}

@end
