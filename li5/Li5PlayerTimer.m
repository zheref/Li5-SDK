//
//  Li5PlayerTimer.m
//  li5
//
//  Created by Martin Cocaro on 6/2/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "Li5PlayerTimer.h"

@interface Li5PlayerTimer ()
{
    id __mTimeRemainingObserver;
}

@property (nonatomic, assign) IBInspectable CGFloat lineWidth;

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat pathRadius;
@property (nonatomic, assign) CGSize shadowSize;

@property (nonatomic, strong) CAShapeLayer *baseLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CATextLayer *timeText;
@property (nonatomic, strong) CALayer *unlockLayer;

@end

@implementation Li5PlayerTimer

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    DDLogDebug(@"");
    _startAngle = M_PI * 1.5;
    _endAngle = _startAngle + (M_PI * 2);
    _percentage = 0.0f;
    _lineWidth = 3.0f;
    _shadowSize = CGSizeMake(2.0,2.0);
    _hasUnlocked = NO;
    
    _baseLayer = [CAShapeLayer layer];
    [_baseLayer setFillColor:[UIColor clearColor].CGColor];
    [_baseLayer setStrokeColor:[UIColor li5_whiteColor].CGColor];
    [_baseLayer setLineWidth:_lineWidth];
    [_baseLayer setLineCap:kCALineCapRound];
    [_baseLayer setMasksToBounds:YES];
    _baseLayer.shadowOffset = _shadowSize;
    _baseLayer.shadowColor = [UIColor blackColor].CGColor;
    _baseLayer.shadowOpacity = 0.25;
    _baseLayer.shadowRadius = 0.0;
    
    _progressLayer = [CAShapeLayer layer];
    [_progressLayer setFillColor:[UIColor clearColor].CGColor];
    [_progressLayer setStrokeColor:[UIColor li5_yellowColor].CGColor];
    [_progressLayer setLineWidth:_lineWidth];
    [_progressLayer setLineCap:kCALineCapRound];
    [_progressLayer setMasksToBounds:YES];
    
    _timeText = [CATextLayer layer];
    _timeText.foregroundColor = (__bridge CGColorRef)([UIColor whiteColor]);
    _timeText.alignmentMode = kCAAlignmentCenter;
    _timeText.contentsGravity = kCAGravityCenter;
    _timeText.contentsScale = [UIScreen mainScreen].scale;
    _timeText.shadowOffset = _shadowSize;
    _timeText.shadowColor = [UIColor blackColor].CGColor;
    _timeText.shadowRadius = 0.0;
    _timeText.shadowOpacity = 0.25;
    
    _unlockLayer = [CALayer layer];
    _unlockLayer.contentsGravity = kCAGravityResizeAspect;
    _unlockLayer.shouldRasterize = YES;
    _unlockLayer.rasterizationScale = [UIScreen mainScreen].scale;
    CGImageRef popcornImage = [UIImage imageNamed:@"popcorn"].CGImage;
    _unlockLayer.contents = (__bridge id _Nullable)(popcornImage);
    
    CABasicAnimation *trans = [CABasicAnimation animationWithKeyPath:@"transform"];
    trans.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.75, 0.75, 1.0)];
    trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    trans.duration = 0.5;
    trans.autoreverses = YES;
    trans.repeatCount = INFINITY;
    trans.removedOnCompletion = NO;
    trans.fillMode = kCAFillModeForwards;
    [_unlockLayer addAnimation:trans forKey:@"pumping"];
    
    [self.layer addSublayer:_baseLayer];
    [self.layer addSublayer:_progressLayer];
    [self.layer addSublayer:_timeText];
    [self.layer addSublayer:_unlockLayer];
}

#pragma mark - UI Setup

- (void)layoutSubviews
{
    [super layoutSubviews];

    _radius = MIN(self.bounds.size.width,self.bounds.size.height) / 2;
    _pathRadius = _radius - _lineWidth - _shadowSize.width;
    CGFloat fontSize = _radius - _lineWidth;
    
    [_baseLayer setLineWidth:_lineWidth];
    [_progressLayer setLineWidth:_lineWidth];
    
    UIBezierPath *fullPath = [self __newPathWithPercentage:1.0 clockwise:YES];
    [_baseLayer setPath:[fullPath CGPath]];
    _baseLayer.frame = self.layer.bounds;
    
    UIBezierPath *progressPath = [self __newPathWithPercentage:self.percentage clockwise:YES];
    [_progressLayer setPath:[progressPath CGPath]];
    _progressLayer.frame = self.layer.bounds;
    
    if (!self.hasUnlocked)
    {
        [self.unlockLayer removeFromSuperlayer];
        
        UIFont *timeFont = [UIFont fontWithName:@"Rubik-Bold" size:fontSize];
        _timeText.font = (__bridge CFTypeRef)timeFont;
        _timeText.fontSize = fontSize;
        _timeText.frame = CGRectInset(self.layer.bounds, 0, timeFont.xHeight);
        if (self.player)
        {
            double remainingTime = MAX(0,CMTimeGetSeconds(self.player.currentItem.asset.duration)*(1-_percentage));
            _timeText.string = [NSString stringWithFormat:@"%li", (long)remainingTime];
        }
    }
    else
    {
        [self.timeText removeFromSuperlayer];
        CGFloat inset = _radius - sqrtf(powf(_radius, 2)/2)/2 - 2*_lineWidth;
        _unlockLayer.frame = CGRectOffset(CGRectInset(self.layer.bounds,inset,inset), 2.0, 0);
    }
    
}

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
 
//    self.hasUnlocked = TRUE;
    self.percentage = 0.3f;
    self.timeText.string = @"12";
    UIImage* image = [UIImage imageNamed:@"popcorn" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:self.traitCollection];

    self.unlockLayer.contents = (__bridge id _Nullable)(image.CGImage);
}

+ (Class)layerClass
{
    return [CALayer class];
}

#pragma mark - Observers

- (void)setupObservers
{
    if (!__mTimeRemainingObserver)
    {
        __weak typeof(self) weakSelf = self;
        __mTimeRemainingObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                                             queue:NULL
                                                                        usingBlock:^(CMTime time) {
                                                                          [weakSelf __updateProgressWithSecondsPlayed:CMTimeGetSeconds(time)];
                                                                        }];
    }
}

- (void)removeObservers
{
    if (__mTimeRemainingObserver)
    {
        [self.player removeTimeObserver:__mTimeRemainingObserver];
        [__mTimeRemainingObserver invalidate];
        __mTimeRemainingObserver = nil;
    }
}

#pragma mark - Public Methods

- (void)setHasUnlocked:(BOOL)hasUnlocked
{
    _hasUnlocked = hasUnlocked;
    
    [self setNeedsLayout];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    
    [self setNeedsLayout];
}

- (void)setPercentage:(CGFloat)percentage
{
    _percentage = percentage;
    
    [self setNeedsLayout];
}

- (void)setPlayer:(AVPlayer *)player
{
    if (_player != player) {
        [self removeObservers];
        
        _player = player;
        
        [self setupObservers];
        
        [self setNeedsLayout];
    }
}

#pragma mark - Private Methods

- (void)__updateProgressWithSecondsPlayed:(CGFloat)timePlayed
{
    double percentage = timePlayed / CMTimeGetSeconds(self.player.currentItem.asset.duration);
    
    UIBezierPath *newPath = [self __newPathWithPercentage:percentage clockwise:YES];
    
    CABasicAnimation *animateStrokEnd = [CABasicAnimation animationWithKeyPath:@"path"];
    animateStrokEnd.duration = 1;
    animateStrokEnd.fromValue = (id)self.progressLayer.path;
    animateStrokEnd.toValue = (id)[newPath CGPath];
    [self.progressLayer addAnimation:animateStrokEnd forKey:nil];
    [self.progressLayer setPath:[newPath CGPath]];
    
    [self setPercentage:percentage];
}

- (UIBezierPath*)__newPathWithPercentage:(CGFloat)newPercentage clockwise:(BOOL)clockwise
{
    CGFloat newEndAngle = (self.endAngle - self.startAngle) * newPercentage + self.startAngle;
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.radius,self.radius)
                                                              radius:self.pathRadius
                                                          startAngle:self.startAngle
                                                            endAngle:newEndAngle
                                                           clockwise:clockwise];
    
    return circlePath;
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [self removeObservers];
}

@end
