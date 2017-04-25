//
//  RecordUIButton.m
//  li5
//
//  Created by Martin Cocaro on 1/24/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//
@import UIKit;

#import "RecordUIButton.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface RecordUIButton ()

@property (nonatomic, assign) IBInspectable double borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *buttonColor;
@property (nonatomic, strong) IBInspectable UIColor *progressColor;
@property (nonatomic, strong) CALayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAGradientLayer *gradientMaskLayer;
@property (nonatomic, assign) BOOL recording;

@end

@implementation RecordUIButton

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    DDLogVerbose(@"");
    TouchDetector *tapRecognizer = [[TouchDetector alloc] initWithTarget:self action:@selector(userDidTap:)];
    [self addGestureRecognizer:tapRecognizer];
    
    _borderWidth = 2.5;
    _buttonColor = [UIColor li5_cyanColor];
    _progressColor = [UIColor li5_violetColor];
    
    _recording = NO;
    
    [self drawButton];
}

#pragma mark - UI Setup

-(void)setProgressColor:(UIColor *)prColor {
    DDLogVerbose(@"");
    _progressColor = prColor;
    
    UIColor *topColor = _progressColor;
    UIColor *bottomColor = _progressColor;
    _gradientMaskLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
}

-(void)setButtonColor:(UIColor *)buttonColor{
    DDLogVerbose(@"");
    _circleLayer.backgroundColor = buttonColor.CGColor;
    
    _buttonColor = buttonColor;
}

- (void)layoutSubviews {
    DDLogVerbose(@"");
    _circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _circleLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
    
    [super layoutSubviews];
}

- (void)drawButton {
    DDLogVerbose(@"");
    self.backgroundColor = [UIColor clearColor];
    
    // Get the root layer
    CALayer *layer = self.layer;
    
    if (!_circleLayer) {
        
        _circleLayer = [CALayer layer];
        _circleLayer.backgroundColor = self.buttonColor.CGColor;
        
        CGFloat size = self.frame.size.width/1.5;
        _circleLayer.bounds = CGRectMake(0, 0, size, size);
        _circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _circleLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
        
        _circleLayer.cornerRadius = size/2;
        
        [layer insertSublayer:_circleLayer atIndex:0];
    }
    
    if (!_progressLayer) {
        
        CGFloat startAngle = M_PI + M_PI_2;
        CGFloat endAngle = M_PI * 3 + M_PI_2;
        CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        _gradientMaskLayer = [self gradientMask];
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:self.frame.size.width/2-2 startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
        _progressLayer.backgroundColor = [UIColor clearColor].CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.strokeColor = [UIColor blackColor].CGColor;
        _progressLayer.lineWidth = 4.0;
        _progressLayer.strokeStart = 0.0;
        _progressLayer.strokeEnd = 0.0;
        
        _gradientMaskLayer.mask = _progressLayer;
        [layer insertSublayer:_gradientMaskLayer atIndex:0];
    }
}

- (CAGradientLayer *)gradientMask {
    DDLogVerbose(@"");
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.locations = @[@0.0, @1.0];
    
    if (!self.progressColor)
        self.progressColor = [UIColor blueColor];
    
    UIColor *topColor = self.progressColor;
    UIColor *bottomColor = self.progressColor;
    
    gradientLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
    
    return gradientLayer;
}

#pragma mark - UIGestureRecognizers

- (void)userDidTap:(UITapGestureRecognizer*)recognizer {
    DDLogVerbose(@"");
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        if (!self.recording) {
            [self animateTouchDown];
            
            _recording = YES;
            
            if (_onRecord) {
                _onRecord();
            }
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (self.recording) {
            [self animateTouchUp];
            
            _recording = NO;
            
            if (_onDoneRecording) {
                _onDoneRecording();
            }
        }
    } else if (recognizer.state == UIGestureRecognizerStateCancelled) {
        
        if (self.recording) {
            [self animateTouchUp];
            
            _recording = NO;
            
            if (_onCancelRecording) {
                _onCancelRecording();
            }
        }
    }
}

- (void)animateTouchDown {
    DDLogVerbose(@"");
    CGFloat duration = 0.15;
    _circleLayer.contentsGravity = @"center";
    
    // Animate main circle
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @1.0;
    scale.toValue = @1.3;
    [scale setDuration:duration];
    scale.fillMode = kCAFillModeForwards;
    scale.removedOnCompletion = NO;
    CABasicAnimation *color = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    [color setDuration:duration];
    color.fillMode = kCAFillModeForwards;
    color.removedOnCompletion = NO;
    color.toValue = (id)self.progressColor.CGColor;
    
    CAAnimationGroup *circleAnimations = [CAAnimationGroup animation];
    circleAnimations.removedOnCompletion = NO;
    circleAnimations.fillMode = kCAFillModeForwards;
    [circleAnimations setDuration:duration];
    [circleAnimations setAnimations:@[scale, color]];
    
    // Animate progress
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = @0.0;
    fadeIn.toValue = @1.0;
    fadeIn.duration = duration;
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    
    [_progressLayer addAnimation:fadeIn forKey:@"fadeIn"];
    [_circleLayer addAnimation:circleAnimations forKey:@"circleAnimations"];
}

- (void)animateTouchUp {
    DDLogVerbose(@"");
    CGFloat duration = 0.15;
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @1.3;
    scale.toValue =   @1.0;
    [scale setDuration:duration];
    scale.fillMode = kCAFillModeForwards;
    scale.removedOnCompletion = NO;
    CABasicAnimation *color = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    color.fillMode = kCAFillModeForwards;
    color.removedOnCompletion = NO;
    color.toValue = (id)self.buttonColor.CGColor;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.removedOnCompletion = NO;
    animations.fillMode = kCAFillModeForwards;
    [animations setDuration:duration]    ;
    [animations setAnimations:@[scale, color]];
    
    // Animate progress
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.fromValue = @1.0;
    fadeOut.toValue = @0.0;
    fadeOut.duration = duration*2;
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = NO;
    
    [_progressLayer addAnimation:fadeOut forKey:@"fadeOut"];
    [_circleLayer addAnimation:animations forKey:@"circleAnimations"];
}

#pragma mark - Public Methods

- (void)setProgress:(CGFloat)newProgress {
    DDLogVerbose(@"");
    _progressLayer.strokeEnd = newProgress;
    if (newProgress >= 1.0 && self.recording){
        _recording = NO;
        
        [self animateTouchUp];
        
        if (_onDoneRecording) {
            _onDoneRecording();
        }
    }
}

@end

@implementation TouchDetector

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.state = UIGestureRecognizerStateEnded;
    }
}

@end
