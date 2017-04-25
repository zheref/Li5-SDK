//
//  RightArrowUIView.m
//  li5
//
//  Created by Martin Cocaro on 1/13/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

#import "RightArrowUIView.h"

@implementation RightArrowUIView

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
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)frame {
    // Drawing code
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: UIColor.blackColor];
    [shadow setShadowOffset: CGSizeMake(-1.1, 1.1)];
    [shadow setShadowBlurRadius: 4];

    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25756 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94157 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.14200 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91080 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21603 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94157 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17447 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93135 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.13600 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75271 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07488 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86825 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07221 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79747 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51124 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48961 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.13638 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22833 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.14165 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07024 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07235 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18373 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11294 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.37879 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07375 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20862 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02753 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.31476 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02912 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.86424 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41204 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.86462 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56639 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.92612 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45518 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.92624 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52312 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.37921 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90680 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25756 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94157 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.34618 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92988 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.30197 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94157 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    bezierPath.miterLimit = 4;
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    bezierPath.lineWidth = 2.0;

    [fillColor setFill];
    [bezierPath fill];
    CGContextRestoreGState(context);

    
}

@end
