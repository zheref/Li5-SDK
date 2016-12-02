//
//  CategoryDecorationsView.m
//  li5
//
//  Created by Martin Cocaro on 6/5/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "CategoryDecorationsView.h"

@interface CategoryDecorationsView ()

@end

@implementation CategoryDecorationsView

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
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat height = CGRectGetHeight(rect);
    CGFloat width = CGRectGetWidth(rect);

    UIBezierPath *vPath = [UIBezierPath bezierPath];

    [vPath moveToPoint:CGPointZero];
    [vPath addLineToPoint:CGPointMake(0, height)];
    [vPath addCurveToPoint:CGPointMake(0.4 * width, 0.4 * height)
             controlPoint1:CGPointMake(0, height)
             controlPoint2:CGPointMake(0.2 * width, 0.2 * height)];
    [vPath addCurveToPoint:CGPointMake(1.1 * width, 0.6 * height)
             controlPoint1:CGPointMake(0.6 * width, 0.6 * height)
             controlPoint2:CGPointMake(width, 0.85 * height)];
    [vPath addLineToPoint:CGPointMake(width, 0)];

    [[UIColor li5_violetColor] setFill];
    [vPath fill];

    UIBezierPath *cPath = [UIBezierPath bezierPath];

    [cPath moveToPoint:CGPointZero];
    [cPath addLineToPoint:CGPointMake(0, 0.65 * height)];
    [cPath addCurveToPoint:CGPointMake(0.4 * width, 0.6 * height)
             controlPoint1:CGPointMake(2.5, 0.7 * height)
             controlPoint2:CGPointMake(0.15 * width, height)];
    [cPath addCurveToPoint:CGPointMake(1.1 * width, 1.25 * height)
             controlPoint1:CGPointMake(0.6 * width, 0.25 * height)
             controlPoint2:CGPointMake(0.74 * width, 6.5)];
    [cPath addLineToPoint:CGPointMake(width, 0)];

    [[UIColor li5_cyanColor] setFill];
    [cPath fill];

    UIBezierPath *rPath = [UIBezierPath bezierPath];

    [rPath moveToPoint:CGPointZero];
    [rPath addLineToPoint:CGPointMake(0, 0.52 * height)];
    [rPath addCurveToPoint:CGPointMake(0.23 * width, 0.6 * height)
             controlPoint1:CGPointMake(1.5, 0.5 * height)
             controlPoint2:CGPointMake(0.1 * width, 0.8 * height)];
    [rPath addCurveToPoint:CGPointMake(0.47 * width, 0.38 * height)
             controlPoint1:CGPointMake(0.37 * width, 0.34 * height)
             controlPoint2:CGPointMake(0.47 * width, 0.38 * height)];
    [rPath addCurveToPoint:CGPointMake(1.08 * width, 0.31 * height)
             controlPoint1:CGPointMake(0.47 * width, 0.38 * height)
             controlPoint2:CGPointMake(0.7 * width, 0.72 * height)];
    [rPath addLineToPoint:CGPointMake(width, 0)];

    [[UIColor li5_redColor] setFill];
    [rPath fill];

    UIBezierPath *yPath = [UIBezierPath bezierPath];

    [yPath moveToPoint:CGPointZero];
    [yPath addLineToPoint:CGPointMake(0, 0.35 * height)];
    [yPath addCurveToPoint:CGPointMake(0.5 * width, 0.35 * height)
             controlPoint1:CGPointMake(0, 0.35 * height)
             controlPoint2:CGPointMake(0.17 * width, 0.86 * height)];
    [yPath addCurveToPoint:CGPointMake(1.34 * width, 0.71 * height)
             controlPoint1:CGPointMake(0.83 * width, -0.17 * height)
             controlPoint2:CGPointMake(1.34 * width, 0.71 * height)];
    [yPath addLineToPoint:CGPointMake(width, 0)];

    [[UIColor li5_yellowColor] setFill];
    [yPath fill];
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

@end
