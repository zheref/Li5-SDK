//
//  ViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "TeaserViewController.h"
#import "ShapesHelper.h"
#import "RootViewController.h"

typedef enum {
    TeaserPlayerLayer = 1,
    FullVideoPlayerLayer = 2
} ActivePlayerLayer;

@interface TeaserViewController () {

    UITapGestureRecognizer *simpleTapGestureRecognizer;
    UILongPressGestureRecognizer *longTapGestureRecognizer;
    
    id mTeaserRemainingObserver;
    id mFullVideoRemainingObserver;
    
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL isSeeking;
    
}

@property (nonatomic, strong) AVPlayerLayer *myPlayerLayerForTeaser;
@property (nonatomic, strong) AVPlayerLayer *myPlayerLayerForFullVideo;
@property (nonatomic, assign) ActivePlayerLayer activePlayerLayer;

@property (nonatomic, strong) UIButton *lockBtn;
@property (nonatomic, strong) UISlider *seekSlider;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *loveBtn;

- (BOOL)isScrubbing;

@end

@implementation TeaserViewController

@synthesize product, unlocked, rendered, hidden, progressLayer, timeText, removableItems;

- (id)initWithProduct:(Product *)thisProduct
{
    self = [super init];
    if (self) {
        //DDLogVerbose(@"Initializing TeaserViewController for: %@", thisProduct.title);
        self.product = thisProduct;

        simpleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        simpleTapGestureRecognizer.delegate = self;
        
        longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        longTapGestureRecognizer.minimumPressDuration = 1.0f;
        longTapGestureRecognizer.allowableMovement = 100.0f;
        longTapGestureRecognizer.delegate = self;
        
        [self playerLayerForTeaser];
        
        rendered = hidden = unlocked = FALSE;
        removableItems = [NSMutableArray<CALayer*> array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //DDLogVerbose(@"Loading TeaserViewController for: %@", self.product.title);
    
    [self.view setBackgroundColor:[UIColor colorWithRed:139.00/255.00 green:223.00/255.00 blue:210.00/255.00 alpha:1.0]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.tag = 19;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    self.loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loveBtn setImage:[UIImage imageNamed:@"Love"] forState:UIControlStateNormal];
    [self.loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateHighlighted];
    [self.loveBtn setImage:[UIImage imageNamed:@"LoveSelected"] forState:UIControlStateSelected];
    [self.loveBtn setFrame:CGRectMake(self.view.frame.size.width-50, self.view.frame.size.height-180, 30, 30)];
    [self.loveBtn addTarget:self action:@selector(loveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loveBtn];
    
    self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareBtn setImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
    [self.shareBtn setImage:[UIImage imageNamed:@"ShareSelected"] forState:UIControlStateHighlighted];
    [self.shareBtn setFrame:CGRectMake(self.view.frame.size.width-50, self.view.frame.size.height-130, 30, 30)];
    [self.shareBtn addTarget:self action:@selector(shareBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareBtn];
    
    [self changeActivePlayerLayerTo:TeaserPlayerLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (self.myPlayerLayerForTeaser != nil) {
        [self.myPlayerLayerForTeaser removeObserver:self forKeyPath:@"readyForDisplay"];
    }
    if (self.myPlayerLayerForFullVideo != nil) {
        [self.myPlayerLayerForFullVideo removeObserver:self forKeyPath:@"readyForDisplay"];
    }
}

#pragma mark - Players

- (AVPlayerLayer *)playerLayerForTeaser {
    if (self.myPlayerLayerForTeaser == nil) {
        DDLogVerbose(@"Creating Teaser Video Player Layer for: %@", self.product.trailerURL);
        Li5Player *player = [[Li5Player alloc] initWithItemAtURL:[NSURL URLWithString:self.product.trailerURL]];
        player.delegate = self;
        
        self.myPlayerLayerForTeaser = [AVPlayerLayer playerLayerWithPlayer:player];
        [self.myPlayerLayerForTeaser addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
        self.myPlayerLayerForTeaser.frame = self.view.bounds;
        self.myPlayerLayerForTeaser.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    return self.myPlayerLayerForTeaser;
}

- (AVPlayerLayer *)playerLayerForFullVideo {
    if (self.myPlayerLayerForFullVideo == nil) {
        DDLogVerbose(@"Creating Full Video Player Layer for: %@", self.product.videoURL);
        Li5Player *player = [[Li5Player alloc] initWithItemAtURL:[NSURL URLWithString:self.product.videoURL]];
        player.delegate = self;
        
        self.myPlayerLayerForFullVideo = [AVPlayerLayer playerLayerWithPlayer:player];
        [self.myPlayerLayerForFullVideo addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
        self.myPlayerLayerForFullVideo.frame = self.view.bounds;
        self.myPlayerLayerForFullVideo.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    return self.myPlayerLayerForFullVideo;
}

- (void)changeActivePlayerLayerTo:(ActivePlayerLayer)newActivePlayerLayer {
    if (self.activePlayerLayer == newActivePlayerLayer) {
        return;
    } else {
        //Displaying Teaser player
        if (newActivePlayerLayer == TeaserPlayerLayer) {
            if (self.myPlayerLayerForFullVideo.superlayer == self.view.layer) {
                [self.myPlayerLayerForFullVideo removeFromSuperlayer];
                [self.myPlayerLayerForFullVideo.player pause];
            }
            
            //[self.view removeGestureRecognizer:simpleTapGestureRecognizer];
            [self removePlayerTimeObserver];
            [self removePlayerFullVideoRemainingTimeObserver];
            
            __weak typeof(self) weakSelf = self;
            mTeaserRemainingObserver = [self.playerLayerForTeaser.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                                            queue:NULL /* If you pass NULL, the main queue is used. */
                                                                       usingBlock:^(CMTime time)
                                        {
                                            [weakSelf updateProgressTimerWithSecondsPlayed:CMTimeGetSeconds(time)];
                                        }];
            
            [[self playerLayerForTeaser].player seekToTime:kCMTimeZero];
            [self.view.layer addSublayer:[self playerLayerForTeaser]];
            [self setActivePlayerLayer:TeaserPlayerLayer];
            if (product.videoURL != nil && ![product.videoURL isEqualToString:@""]) {
                [self.view addGestureRecognizer:longTapGestureRecognizer];
            }
        //Displaying Full Video player
        } else if (newActivePlayerLayer == FullVideoPlayerLayer) {
            if (self.myPlayerLayerForTeaser.superlayer == self.view.layer) {
                [self.myPlayerLayerForTeaser removeFromSuperlayer];
                [self.myPlayerLayerForTeaser.player pause];
            }
            
            //[self.view removeGestureRecognizer:simpleTapGestureRecognizer];
            [self.view removeGestureRecognizer:longTapGestureRecognizer];
            [self removePlayerTeaserRemainingTimeObserver];
            
            __weak typeof(self) weakSelf = self;
            mFullVideoRemainingObserver = [self.playerLayerForFullVideo.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                                               queue:NULL /* If you pass NULL, the main queue is used. */
                                                                          usingBlock:^(CMTime time)
                                           {
                                               [weakSelf updatedProgressTimerWithSecondsRemainingForFullVideo:CMTimeGetSeconds(time)];
                                           }];
            
            [[self playerLayerForFullVideo].player seekToTime:kCMTimeZero];
            [self.view.layer addSublayer:[self playerLayerForFullVideo]];
            [self setActivePlayerLayer:FullVideoPlayerLayer];
        }
    }
}

- (AVPlayer *) currentPlayer {
    return [[self myActivePlayerLayer] player];
}

- (AVPlayerLayer *)myActivePlayerLayer {
    if (self.activePlayerLayer == TeaserPlayerLayer) {
        return self.myPlayerLayerForTeaser;
    } else if (self.activePlayerLayer == FullVideoPlayerLayer) {
        return self.myPlayerLayerForFullVideo;
    } else {
        return nil;
    }
}

- (void)lockVideo {
    self.unlocked = false;
    [self.lockBtn removeFromSuperview];
    [self.seekSlider removeFromSuperview];
    [self.timeLabel removeFromSuperview];
}

- (void)hideAndMoveToViewController:(UIViewController *)viewController
{
    DDLogVerbose(@">>>>>>>>>>>> HIDE %@. <<<<<<<<<<<<", [(AVURLAsset *)[self myActivePlayerLayer].player.currentItem.asset URL]);
    
    DDLogVerbose(@"User saw %@ (%@) during %f", self.product.id, self.product.title, CMTimeGetSeconds([self myActivePlayerLayer].player.currentTime));
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 postUserWatchedVideoWithId:self.product.id during:[NSNumber numberWithFloat:CMTimeGetSeconds([self myActivePlayerLayer].player.currentTime)] withCompletion:^(NSError *error) {
        DDLogVerbose(@"Error: %@", error.localizedDescription);
    }];

    [[self myActivePlayerLayer].player pause];
    self.hidden = TRUE;
    if ([viewController isKindOfClass:[ProductPageViewController class]] && self.activePlayerLayer == FullVideoPlayerLayer) {
        [self lockVideo];
        [self.myPlayerLayerForFullVideo removeObserver:self forKeyPath:@"readyForDisplay"];
        self.myPlayerLayerForFullVideo.player = nil;
        self.myPlayerLayerForFullVideo = nil;
    }
}

- (void)show
{
    DDLogVerbose(@">>>>>>>>>>>> SHOW %@. <<<<<<<<<<<<", [(AVURLAsset *)[self myActivePlayerLayer].player.currentItem.asset URL]);
    self.hidden = FALSE;
    
    if (self.unlocked == true && self.activePlayerLayer == TeaserPlayerLayer) {
        [self changeActivePlayerLayerTo:FullVideoPlayerLayer];
    } else if (self.unlocked == false && self.activePlayerLayer == FullVideoPlayerLayer) {
        [self changeActivePlayerLayerTo:TeaserPlayerLayer];
    }
    
    [self renderAnimations];
    [[self myActivePlayerLayer].player play];
}

- (void)redisplay
{
    [[self myActivePlayerLayer].player seekToTime:kCMTimeZero];
    [self show];
}

#pragma mark - Gestures handling and actions

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (unlocked) {
            if ([self myActivePlayerLayer].player.rate > 0 && [self myActivePlayerLayer].player.error == nil )
            {
                [[self myActivePlayerLayer].player pause];
            } else
            {
                [[self myActivePlayerLayer].player play];
            }
        }
    }
}

- (void)unlock: (UITapGestureRecognizer *) sender
{
    
    self.unlocked = TRUE;
    
    [self changeActivePlayerLayerTo:FullVideoPlayerLayer];
    
    [self removeAnimations];
    
    if (!self.lockBtn) {
        self.lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.lockBtn setFrame:CGRectMake(20, 20, 30, 30)];
        [self.lockBtn setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
        [self.lockBtn setImage:[UIImage imageNamed:@"CloseSelected"] forState:UIControlStateHighlighted];
        [self.lockBtn addTarget:self action:@selector(lockBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:self.lockBtn];
    
    if (!self.seekSlider) {
        self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(100, 30, self.view.frame.size.width-200, 10)];
        [self.seekSlider addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
        [self.seekSlider addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
        [self.seekSlider addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
        [self.seekSlider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
        [self.seekSlider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
        [self.seekSlider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel];
        
        isSeeking = NO;
    }
    [self.view addSubview:self.seekSlider];
    
    if (!self.timeLabel) {
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, 20, 40, 40)];
        [self.timeLabel setTextColor:[UIColor whiteColor]];
    }
    [self.view addSubview:self.timeLabel];
    
    //Long Tap transparent Background Rectangle
    CGFloat animationDuration = 0.5f;
    CGFloat fromRadius = 50.0f;
    CGFloat toRadius = 800.0f;
    
    CGPoint touchPosition = [sender locationInView:self.view];
    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(touchPosition.x,touchPosition.y,100,100)];
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
        circleView.frame = CGRectMake(-800,-500,2*toRadius,2*toRadius);
    } completion:^(BOOL finished) {
        [circleView removeFromSuperview];
    }];
    
    [self.view bringSubviewToFront:self.shareBtn];
    [self.view bringSubviewToFront:self.loveBtn];
}

- (void)handleLongTap:(UITapGestureRecognizer *)sender
{
    if (self.activePlayerLayer == TeaserPlayerLayer)
    {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            if (!self.unlocked)
            {
                [self unlock:sender];
            }
        }
    }
}

- (void)lockBtnPressed:(UIButton *)button {
    [self lockVideo];
    [self changeActivePlayerLayerTo:TeaserPlayerLayer];
    [self redisplay];
}

- (void)shareBtnPressed:(UIButton *)button {
    DDLogVerbose(@"Share Button Pressed");
    NSString *textToShare = @"Look at this awesome product!";
    NSURL *productURL = [NSURL URLWithString:[[[[Li5ApiHandler sharedInstance] baseURL] stringByAppendingPathComponent:@"p"] stringByAppendingPathComponent:self.product.slug]];
    
    NSArray *objectsToShare = @[textToShare, productURL];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypePostToWeibo,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToTencentWeibo,
                                   UIActivityTypeAirDrop];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)loveBtnPressed:(UIButton *)button {
    DDLogVerbose(@"Love Button Pressed");
    if (button.selected) {
        [button setSelected:false];
        [[Li5ApiHandler sharedInstance] deleteLoveForProductWithSlug:self.product.slug withCompletion:^(NSError *error) {
            if (error != nil) {
                [button setSelected:true];
            }
        }];
    } else {
        [button setSelected:true];
        [[Li5ApiHandler sharedInstance] postLoveForProductWithSlug:self.product.slug withCompletion:^(NSError *error) {
            if (error != nil) {
                [button setSelected:false];
            }
        }];
    }
}

#pragma mark -
#pragma mark Movie scrubber control

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
    if (!mTimeObserver) {
        double interval = .1f;
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([self.seekSlider bounds]);
            interval = 0.5f * duration / width;
        }
        
        /* Update the scrubber during normal playback. */
        __weak TeaserViewController *weakSelf = self;
        mTimeObserver = [[self currentPlayer] addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                           queue:NULL /* If you pass NULL, the main queue is used. */
                                                                      usingBlock:^(CMTime time)
                         {
                             [weakSelf syncScrubber];
                         }];
        DDLogVerbose(@"init scrubber with %@",mTimeObserver);
    }
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        _seekSlider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [self.seekSlider minimumValue];
        float maxValue = [self.seekSlider maximumValue];
        double time = CMTimeGetSeconds([[self currentPlayer] currentTime]);
        
        [self.seekSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (void)beginScrubbing:(id)sender
{
    DDLogVerbose(@"begin scrubbing with: %@", mTimeObserver);
    
    mRestoreAfterScrubbingRate = [[self currentPlayer] rate];
    [[self currentPlayer] setRate:0.f];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
- (void)scrub:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]] && !isSeeking)
    {
        //DDLogVerbose(@"scrubbing");
        isSeeking = YES;
        UISlider* slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            DDLogVerbose(@"seeking to time %f",time);
            [[self currentPlayer] seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    isSeeking = NO;
                });
            }];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (void)endScrubbing:(id)sender
{
    DDLogVerbose(@"end scrubbing with %@", mTimeObserver);
    if (!mTimeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([self.seekSlider bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak TeaserViewController *weakSelf = self;
            mTimeObserver = [[self currentPlayer] addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                             ^(CMTime time)
                             {
                                 [weakSelf syncScrubber];
                             }];
        }
    }
    
    if (mRestoreAfterScrubbingRate)
    {
        [[self currentPlayer] setRate:mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate = 0.f;
    }
}

- (BOOL)isScrubbing
{
    return mRestoreAfterScrubbingRate != 0.f;
}

-(void)enableScrubber
{
    self.seekSlider.enabled = YES;
}

-(void)disableScrubber
{
    self.seekSlider.enabled = NO;
}

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [[self currentPlayer] currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

-(void)removePlayerTimeObserver
{
    if (mTimeObserver)
    {
        //DDLogVerbose(@"removing %@ from player %@",timeObserver,[self currentPlayer]);
        [[self currentPlayer] removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}

-(void)removePlayerTeaserRemainingTimeObserver
{
    if (mTeaserRemainingObserver)
    {
        //DDLogVerbose(@"removing %@ from player %@",timeObserver,[self currentPlayer]);
        [[self currentPlayer] removeTimeObserver:mTeaserRemainingObserver];
        mTeaserRemainingObserver = nil;
    }
}

-(void)removePlayerFullVideoRemainingTimeObserver
{
    if (mFullVideoRemainingObserver)
    {
        //DDLogVerbose(@"removing %@ from player %@",timeObserver,[self currentPlayer]);
        [[self currentPlayer] removeTimeObserver:mFullVideoRemainingObserver];
        mFullVideoRemainingObserver = nil;
    }
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSString *videoName = [[(AVURLAsset*)[self myActivePlayerLayer].player.currentItem.asset URL] lastPathComponent];
    if ([keyPath isEqualToString:@"readyForDisplay"]) {
        DDLogVerbose(@"Ready for display %@", videoName);
        //Stop spinner
        [[self.view viewWithTag:19] stopAnimating];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Li5PlayerDelegate

- (void)li5Player:(Li5Player *)li5Player changedStatusForPlayerItem:(AVPlayerItem *)playerItem withStatus:(AVPlayerItemStatus)status {
    if (status == AVPlayerStatusReadyToPlay && [self isViewLoaded] && self.view.window && !hidden) {
        if (li5Player == [self myActivePlayerLayer].player && [self currentPlayer].rate == 0.f && ![self isScrubbing]) {
            DDLogVerbose(@"Ready to play for: %@ at %@", self.product.title, [(AVURLAsset *)li5Player.currentItem.asset URL]);
            [self renderAnimations];
            [li5Player play];
            if (unlocked) {
                [self initScrubberTimer];
                [self syncScrubber];
            }
        }
    }
}

- (void)li5Player:(Li5Player *)li5Player updatedLoadedSecondsForPlayerItem:(AVPlayerItem *)playerItem withSeconds:(CGFloat)seconds {
    //DDLogVerbose(@"%@ at %@ ---> Loaded %f seconds of %f", [[(AVURLAsset *)playerItem.asset URL] lastPathComponent], [(AVURLAsset *)playerItem.asset URL], seconds, CMTimeGetSeconds(playerItem.duration));
}

#pragma mark - Animations

- (void)removeAnimations {
    if (rendered)
    {
        DDLogVerbose(@"removing animations");
        [removableItems makeObjectsPerformSelector:@selector(removeAllAnimations)];
        [removableItems makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [removableItems removeAllObjects];
        progressLayer = nil;
        timeText = nil;
        [self.view setNeedsDisplay];
        rendered = FALSE;
    }
}

- (void)renderAnimations {
    [self removeAnimations];
    DDLogVerbose(@"rendering animations");
    if (!self.unlocked) {
        UIFont *categoryFont = [UIFont fontWithName:@"Avenir-Black" size:15.0];
        NSString *category = self.product.categoryName;
        CGRect categorySize = [category boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:categoryFont} context:nil];
        
        CAShapeLayer *categoryLayer = [CAShapeLayer layer];
        UIBezierPath *hexagonPath = [ShapesHelper hexagonWithWidth:categorySize.size.width andHeight:categorySize.size.height + 24];
        hexagonPath.lineJoinStyle = kCGLineJoinRound;
        hexagonPath.lineCapStyle = kCGLineCapRound;
        [categoryLayer setPath:[hexagonPath CGPath]];
        [categoryLayer setFrame:CGRectMake(25,17,hexagonPath.bounds.size.width, hexagonPath.bounds.size.height)];
        [categoryLayer setFillColor:[[UIColor blackColor] CGColor]];
        [categoryLayer setLineCap:kCALineCapRound];
        [categoryLayer setLineJoin:kCALineJoinRound];
        
        CATextLayer *categoryText = [CATextLayer layer];
        categoryText.frame = CGRectMake(0,12,hexagonPath.bounds.size.width, hexagonPath.bounds.size.height);
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
        [lineLayer setPosition:CGPointMake(0,categoryLayer.position.y)];
        
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
        extendToLeft.beginTime = CACurrentMediaTime()+1.0;
        [lineLayer addAnimation:extendToLeft forKey:@"extendToLeft"];
        
        [self.view.layer addSublayer:lineLayer];
        [self.view.layer addSublayer:categoryLayer];
        [categoryLayer addSublayer:categoryText];
        
        [self.removableItems addObject:lineLayer];
        [self.removableItems addObject:categoryLayer];
    }
    
    /*
     //DDLogVerbose(@"Rendering animations for: %@", self.product.title);
     UIFont *headlineFont = [UIFont fontWithName:@"Avenir-Black" size:22.0];
     CGRect headlineSize = [self.product.title boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 50, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:headlineFont} context:nil];
     
     //White Background Rectangle
     CAShapeLayer *titleBackgroundLayer = [CAShapeLayer layer];
     CGRect titleFrame = CGRectMake(25, self.view.frame.size.height - headlineSize.size.height - 60, self.view.frame.size.width - 50,headlineSize.size.height + 10);
     [titleBackgroundLayer setPath:[[UIBezierPath bezierPathWithRect:titleFrame] CGPath]];
     [titleBackgroundLayer setStrokeColor:[[UIColor blackColor] CGColor]];
     [titleBackgroundLayer setLineWidth:3.0];
     [titleBackgroundLayer setFillColor:[[UIColor whiteColor] CGColor]];
     
     //Product Headline
     CATextLayer *headline = [CATextLayer layer];
     headline.frame = titleFrame;
     headline.position = CGPointMake(titleFrame.origin.x + titleFrame.size.width/2, titleFrame.origin.y + titleFrame.size.height/2 + 5);
     headline.string = self.product.title;
     headline.font = (__bridge CFTypeRef)headlineFont;
     headline.fontSize = 22.0;
     headline.foregroundColor = (__bridge CGColorRef)([UIColor blackColor]);
     headline.wrapped = true;
     headline.alignmentMode = kCAAlignmentCenter;
     headline.contentsGravity = kCAGravityCenter;
     headline.contentsScale = [UIScreen mainScreen].scale;
     
     //Add title background rectangle to view
     [self.view.layer addSublayer:titleBackgroundLayer];
     [self.removableItems addObject:titleBackgroundLayer];
     
     //Add Product headline to view
     [self.view.layer addSublayer:headline];
     [self.removableItems addObject:headline];
     */
    
    //Triangle up selection
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(0, 10)];
    [trianglePath addLineToPoint:CGPointMake(5,5)];
    [trianglePath addLineToPoint:CGPointMake(10,10)];
    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
    [triangleMaskLayer setPath:trianglePath.CGPath];
    [triangleMaskLayer setBorderColor:[[UIColor whiteColor] CGColor]];
    [triangleMaskLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [triangleMaskLayer setFillColor:[[UIColor clearColor] CGColor]];
    CGPoint triangleMaskLayerPosition = CGPointMake(self.view.frame.size.width/2-5, self.view.frame.size.height-35);
    [triangleMaskLayer setPosition:triangleMaskLayerPosition];
    
    [self.view.layer addSublayer:triangleMaskLayer];
    [self.removableItems addObject:triangleMaskLayer];
    
    CABasicAnimation *moveUpAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveUpAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    moveUpAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2-5,self.view.frame.size.height+50)];
    moveUpAnimation.toValue = [NSValue valueWithCGPoint:triangleMaskLayerPosition];
    moveUpAnimation.duration = 1.0f;
    
    [triangleMaskLayer addAnimation:moveUpAnimation forKey:@"position"];
    
    //Read More text
    CATextLayer *readMore = [CATextLayer layer];
    readMore.frame = CGRectMake(0, self.view.frame.size.height-20, self.view.frame.size.width, 20);
    readMore.contentsGravity = kCAGravityCenter;
    readMore.alignmentMode = kCAAlignmentCenter;
    readMore.string = @"MORE";
    readMore.font = (__bridge CFTypeRef)([UIFont systemFontOfSize:12.0]);
    readMore.fontSize = 12.0;
    readMore.foregroundColor = (__bridge CGColorRef)([UIColor whiteColor]);
    readMore.contentsScale = [UIScreen mainScreen].scale;
    
    [self.view.layer addSublayer:readMore];
    [self.removableItems addObject:readMore];
    
    moveUpAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height+30)];
    moveUpAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height-10)];
    
    [readMore addAnimation:moveUpAnimation forKey:@"position"];
    
    [self.view bringSubviewToFront:self.shareBtn];
    [self.view bringSubviewToFront:self.loveBtn];
    
    rendered = TRUE;
}

- (void)updateProgressTimerWithSecondsPlayed:(CGFloat)timePlayed
{
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    CGFloat startAngle = M_PI * 1.5;
    CGFloat endAngle = startAngle + (M_PI * 2);
    
    double remainingTime = CMTimeGetSeconds([self myActivePlayerLayer].player.currentItem.asset.duration) - timePlayed;
    double percentage = remainingTime / CMTimeGetSeconds([self myActivePlayerLayer].player.currentItem.asset.duration);
    
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
        timeText.frame = CGRectMake(progressCenter.x - 10,progressCenter.y - 8,20,20);
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
    
    timeText.string = [NSString stringWithFormat:@"%li",(long)remainingTime];
}

- (void)updatedProgressTimerWithSecondsRemainingForFullVideo:(CGFloat)seconds {
    if (CMTimeGetSeconds([self currentPlayer].currentItem.duration) >= 0) {
        float timeRemaining = CMTimeGetSeconds([self currentPlayer].currentItem.duration) - seconds;
        if (timeRemaining >= 0) {
            self.timeLabel.text = [NSString stringWithFormat:@"%.0f", timeRemaining];
        }
    } else {
        self.timeLabel.text = @"";
    }
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    DDLogVerbose(@"animationDidStart");
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    DDLogVerbose(@"animationDidStop finished");
}

@end