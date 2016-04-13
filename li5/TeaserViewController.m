//
//  ViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "TeaserViewController.h"
#import "ShapesHelper.h"

@interface TeaserViewController () {
    AVPlayerItem *trailerPlayerItem;
    AVPlayerItem *videoPlayerItem;
}

@end

@implementation TeaserViewController

@synthesize _playerLayer, product, unlocked, rendered, hidden, progressLayer, timeText, removableItems;

- (id)initWithProduct:(Product *)thisProduct
{
    self = [super init];
    if (self) {
        //DDLogVerbose(@"Initializing TeaserViewController for: %@", thisProduct.title);
        self.product = thisProduct;
        //Initializing video player
        [self playerLayer];
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
    
    /*
    //Load still image while video loads
    UIImage *stillImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.product.still]]];
    UIImageView *stillImageView = [[UIImageView alloc] initWithImage:stillImage];
    [stillImageView setContentMode:UIViewContentModeScaleAspectFill];
    [stillImageView setFrame:self.view.bounds];
    [self.view addSubview:stillImageView];
     */
    
    //Add Video Player AVPlayer Layer to window frame
    [self.view.layer addSublayer:self.playerLayer];
}

-(AVPlayerLayer*)playerLayer {
    if(!_playerLayer){
        DDLogVerbose(@"Creating Video Player instance for: %@", self.product.trailerURL);
        NSURL *videoUrl = nil;
        if ([self.product.trailerURL hasPrefix:@"local://"])
        {
            NSString *moviePath = [[NSBundle mainBundle] pathForResource:[self.product.trailerURL substringFromIndex:[@"local://" length]] ofType:@"mp4"];
            videoUrl = [NSURL fileURLWithPath:moviePath];
        } else {
            videoUrl = [NSURL URLWithString:self.product.trailerURL];
        }
        trailerPlayerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        [trailerPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [trailerPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
        AVPlayer *player = [[AVPlayer alloc]initWithPlayerItem:trailerPlayerItem];
        [player addPeriodicTimeObserverForInterval:CMTimeMake([self.product.trailerDuration integerValue]*10, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            if ( CMTIME_COMPARE_INLINE( time, >= , CMTimeMake([self.product.trailerDuration integerValue]*10, 10) ) && !unlocked)
            {
                [self redisplay];
            }
        }];
        [player addPeriodicTimeObserverForInterval:CMTimeMake(10, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [self updateProgressTimerWithSecondsPlayed:(CMTimeGetSeconds(time))];
        }];
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        [_playerLayer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
        _playerLayer.frame = self.view.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        UITapGestureRecognizer *videoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        videoTap.delegate = self;
        [self.view addGestureRecognizer:videoTap];
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        longTap.minimumPressDuration = 1.0f;
        longTap.allowableMovement = 100.0f;
        longTap.delegate = self;
        [self.view addGestureRecognizer:longTap];
    }
    return _playerLayer;
}

- (void) renderAnimations {
    if ( rendered )
    {
        DDLogVerbose(@"removing animations");
        [removableItems makeObjectsPerformSelector:@selector(removeAllAnimations)];
        [removableItems makeObjectsPerformSelector:@selector(removeFromSuperlayer) ];
        [removableItems removeAllObjects];
        [self.view setNeedsDisplay];
        rendered = FALSE;
    }
    DDLogVerbose(@"rendering animations");
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
    rendered = TRUE;
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    DDLogVerbose(@"animationDidStart");
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    DDLogVerbose(@"animationDidStop finished");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSString *videoName = [[(AVURLAsset*)self._playerLayer.player.currentItem.asset URL] lastPathComponent];
    /*
    NSArray *loadedTimeRanges = self._playerLayer.player.currentItem.loadedTimeRanges;
    if ( loadedTimeRanges.count > 0 ) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
        DDLogVerbose(@"teaser video %@: %f sec",videoName, durationSeconds);
    }
     */
    
    if ([keyPath isEqualToString:@"readyForDisplay"] && self._playerLayer.readyForDisplay ) {
        DDLogVerbose(@"Ready for display %@",videoName);
        //Stop spinner
        [[self.view viewWithTag:19] stopAnimating];
    }
    
    if ([self isViewLoaded] && self.view.window && object == self._playerLayer.player.currentItem)
    {
        if ([keyPath isEqualToString:@"status"] && self._playerLayer.player.currentItem.status == AVPlayerStatusReadyToPlay && !hidden) {
            DDLogVerbose(@"Ready to play for: %@", videoName);
            
            if (!rendered)
            {
                [self renderAnimations];
            }
            
            [self._playerLayer.player play];
        }
    }
}

- (void) updateProgressTimerWithSecondsPlayed:(CGFloat)timePlayed
{
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    CGFloat startAngle = M_PI * 1.5;
    CGFloat endAngle = startAngle + (M_PI * 2);
    
    double remainingTime = CMTimeGetSeconds(self._playerLayer.player.currentItem.asset.duration) - timePlayed;
    double percentage = remainingTime / CMTimeGetSeconds(self._playerLayer.player.currentItem.asset.duration);
    
    CGPoint progressCenter = CGPointMake(self.view.frame.size.width - 30, 38);
    
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:progressCenter
                          radius:17
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * percentage + startAngle
                       clockwise:NO];

    if ( progressLayer == nil )
    {
        progressLayer = [CAShapeLayer layer];
        [progressLayer setFillColor:[UIColor clearColor].CGColor];
        [progressLayer setStrokeColor:[UIColor whiteColor].CGColor];
        [progressLayer setLineWidth:3.0];
        [progressLayer setLineCap:kCALineCapRound];
        
        [progressLayer setZPosition:100];
        
        [self.view.layer addSublayer:progressLayer];
        
        CAShapeLayer *timerLayer = [CAShapeLayer layer];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:progressCenter radius:16 startAngle:startAngle endAngle:endAngle clockwise:YES];
        [timerLayer setFillColor:[UIColor blackColor].CGColor];
        [timerLayer setPath:[circlePath CGPath]];
        
        [timerLayer setZPosition:101];
        
        [self.view.layer addSublayer:timerLayer];
        
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
    }
    
    CABasicAnimation *animateStrokEnd = [CABasicAnimation animationWithKeyPath:@"path"];
    animateStrokEnd.duration = 1;
    animateStrokEnd.fromValue = (id)progressLayer.path;
    animateStrokEnd.toValue = (id)[bezierPath CGPath];
    [progressLayer addAnimation:animateStrokEnd forKey:nil];
    [progressLayer setPath:[bezierPath CGPath]];
    
    timeText.string = [NSString stringWithFormat:@"%li",(long)remainingTime];

}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    //DDLogDebug(@"Tap");
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if ( unlocked ) {
            if (_playerLayer.player.rate > 0 && _playerLayer.player.error == nil )
            {
                [_playerLayer.player pause];
            } else
            {
                [_playerLayer.player play];
            }
        }
    }
}

- (void) hide
{
    NSLog(@"User saw %@ (%@) during %f", self.product.id, self.product.title, CMTimeGetSeconds(_playerLayer.player.currentTime));
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 postUserWatchedVideoWithId:self.product.id during:[NSNumber numberWithFloat:CMTimeGetSeconds(_playerLayer.player.currentTime)] withCompletion:^(NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    [_playerLayer.player pause];
    self.hidden = TRUE;
}

- (void) show
{
    self.hidden = FALSE;
    [self renderAnimations];
    [_playerLayer.player play];
}

- (void) redisplay
{
    [_playerLayer.player seekToTime:kCMTimeZero];
    [self show];
}

- (void)handleLongTap:(UITapGestureRecognizer *)sender
{
    //DDLogDebug(@"Long Tap");
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if ( !self.unlocked )
        {
            //unlock video
            self.unlocked = TRUE;
            
            [trailerPlayerItem removeObserver:self forKeyPath:@"status" context:nil];
            [trailerPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
            
            videoPlayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.product.videoURL]];
            [videoPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            [videoPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            [self._playerLayer.player replaceCurrentItemWithPlayerItem:videoPlayerItem];
            
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

        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
