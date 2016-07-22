//
//  Heart.m
//  Heart
//
//  Created by Martin Cocaro on 7/1/16.
//  Copyright (c) 2016 ThriveCom. All rights reserved.

#import "Heart.h"


@implementation FullHeart

-(void)drawInContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    
    //// Color Declarations
    UIColor* fillColor3 = [UIColor colorWithRed: 0.894 green: 0 blue: 0.185 alpha: 1];
    
    
    //// Subframes
    CGRect group2 = CGRectMake(CGRectGetMinX(self.bounds) + 0.2, CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds) - 0.39, CGRectGetHeight(self.bounds) - 0);
    CGFloat minX = CGRectGetMinX(group2);
    CGFloat minY = CGRectGetMinY(group2);
    CGFloat width = CGRectGetWidth(group2);
    CGFloat height = CGRectGetHeight(group2);
    
    
    //// Group 2
    {
        CGContextSaveGState(context);
        CGContextBeginTransparencyLayer(context, NULL);
        
        //// Clip Clip
        UIBezierPath* clipPath = [UIBezierPath bezierPath];
        [clipPath moveToPoint: CGPointMake(minX + 0.77406 * width, minY + 0.00000 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.50702 * width, minY + 0.18659 * height) controlPoint1: CGPointMake(minX + 0.66405 * width, minY + 0.00000 * height) controlPoint2: CGPointMake(minX + 0.55047 * width, minY + 0.07085 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.49301 * width, minY + 0.18599 * height) controlPoint1: CGPointMake(minX + 0.50457 * width, minY + 0.19320 * height) controlPoint2: CGPointMake(minX + 0.49563 * width, minY + 0.19280 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.25761 * width, minY + 0.00000 * height) controlPoint1: CGPointMake(minX + 0.45099 * width, minY + 0.07651 * height) controlPoint2: CGPointMake(minX + 0.36235 * width, minY + 0.00000 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.00000 * width, minY + 0.31785 * height) controlPoint1: CGPointMake(minX + 0.11249 * width, minY + 0.00000 * height) controlPoint2: CGPointMake(minX + 0.00000 * width, minY + 0.13879 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.05742 * width, minY + 0.51790 * height) controlPoint1: CGPointMake(minX + 0.00000 * width, minY + 0.39376 * height) controlPoint2: CGPointMake(minX + 0.04548 * width, minY + 0.49492 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.41383 * width, minY + 0.93835 * height) controlPoint1: CGPointMake(minX + 0.13644 * width, minY + 0.66331 * height) controlPoint2: CGPointMake(minX + 0.41383 * width, minY + 0.93835 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.50031 * width, minY + 1.00000 * height) controlPoint1: CGPointMake(minX + 0.43833 * width, minY + 0.96985 * height) controlPoint2: CGPointMake(minX + 0.46748 * width, minY + 1.00000 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.59127 * width, minY + 0.94388 * height) controlPoint1: CGPointMake(minX + 0.53136 * width, minY + 1.00000 * height) controlPoint2: CGPointMake(minX + 0.56709 * width, minY + 0.97252 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.90965 * width, minY + 0.60719 * height) controlPoint1: CGPointMake(minX + 0.59127 * width, minY + 0.94388 * height) controlPoint2: CGPointMake(minX + 0.85714 * width, minY + 0.67040 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 1.00000 * width, minY + 0.31861 * height) controlPoint1: CGPointMake(minX + 0.97983 * width, minY + 0.52272 * height) controlPoint2: CGPointMake(minX + 1.00000 * width, minY + 0.39719 * height)];
        [clipPath addCurveToPoint: CGPointMake(minX + 0.77406 * width, minY + 0.00000 * height) controlPoint1: CGPointMake(minX + 1.00000 * width, minY + 0.13585 * height) controlPoint2: CGPointMake(minX + 0.92221 * width, minY + 0.00000 * height)];
        [clipPath closePath];
        clipPath.usesEvenOddFillRule = YES;
        
        [clipPath addClip];
        
        
//        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(minX + floor(width * -0.15618 + 0.5), minY + floor(height * -0.21054 - 0.5) + 1, floor(width * 1.15581 - 0.1) - floor(width * -0.15618 + 0.5) + 0.6, floor(height * 1.21067 - 0.5) - floor(height * -0.21054 - 0.5))];
        [fillColor3 setFill];
        [rectanglePath fill];
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    UIGraphicsPopContext();
    
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [self drawInContext:ctx];
}

@end


@implementation EmptyHeart

-(void)drawInContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    
    
    //// Subframes
    CGRect group2 = CGRectMake(CGRectGetMinX(self.bounds) + 0.2, CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds) - 0.39, CGRectGetHeight(self.bounds) - 0);
    CGFloat minX = CGRectGetMinX(group2);
    CGFloat minY = CGRectGetMinY(group2);
    CGFloat width = CGRectGetWidth(group2);
    CGFloat height = CGRectGetHeight(group2);
    
    
    //// Group 2
    {
        CGContextSaveGState(context);
        CGContextBeginTransparencyLayer(context, NULL);
        
//        UIColor* fillColor = [UIColor colorWithRed: 0.894 green: 0 blue: 0.185 alpha: 1];
        UIColor* fillColor = [UIColor whiteColor];
        
        //// Bezier 4 Drawing
        UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
        [bezier4Path moveToPoint: CGPointMake(minX + 0.48305 * width, minY + 0.62010 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.10203 * width, minY + 0.33760 * height) controlPoint1: CGPointMake(minX + 0.30885 * width, minY + 0.62010 * height) controlPoint2: CGPointMake(minX + 0.10203 * width, minY + 0.48125 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.27983 * width, minY + 0.12206 * height) controlPoint1: CGPointMake(minX + 0.10203 * width, minY + 0.23067 * height) controlPoint2: CGPointMake(minX + 0.16370 * width, minY + 0.12206 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.48584 * width, minY + 0.34675 * height) controlPoint1: CGPointMake(minX + 0.40446 * width, minY + 0.12206 * height) controlPoint2: CGPointMake(minX + 0.45629 * width, minY + 0.28115 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.51156 * width, minY + 0.34861 * height) controlPoint1: CGPointMake(minX + 0.49386 * width, minY + 0.36447 * height) controlPoint2: CGPointMake(minX + 0.50288 * width, minY + 0.36528 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.74433 * width, minY + 0.12206 * height) controlPoint1: CGPointMake(minX + 0.54503 * width, minY + 0.28425 * height) controlPoint2: CGPointMake(minX + 0.61187 * width, minY + 0.12206 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.89130 * width, minY + 0.33760 * height) controlPoint1: CGPointMake(minX + 0.86407 * width, minY + 0.12206 * height) controlPoint2: CGPointMake(minX + 0.89130 * width, minY + 0.22981 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.48305 * width, minY + 0.62010 * height) controlPoint1: CGPointMake(minX + 0.89130 * width, minY + 0.48125 * height) controlPoint2: CGPointMake(minX + 0.65725 * width, minY + 0.62010 * height)];
        [bezier4Path closePath];
        [bezier4Path moveToPoint: CGPointMake(minX + 0.76398 * width, minY + 0.00497 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.50473 * width, minY + 0.18662 * height) controlPoint1: CGPointMake(minX + 0.65718 * width, minY + 0.00497 * height) controlPoint2: CGPointMake(minX + 0.54691 * width, minY + 0.07395 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.49113 * width, minY + 0.18604 * height) controlPoint1: CGPointMake(minX + 0.50235 * width, minY + 0.19306 * height) controlPoint2: CGPointMake(minX + 0.49367 * width, minY + 0.19267 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.26260 * width, minY + 0.00497 * height) controlPoint1: CGPointMake(minX + 0.45033 * width, minY + 0.07945 * height) controlPoint2: CGPointMake(minX + 0.36428 * width, minY + 0.00497 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.01250 * width, minY + 0.31442 * height) controlPoint1: CGPointMake(minX + 0.12171 * width, minY + 0.00497 * height) controlPoint2: CGPointMake(minX + 0.01250 * width, minY + 0.14009 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.06825 * width, minY + 0.50917 * height) controlPoint1: CGPointMake(minX + 0.01250 * width, minY + 0.38832 * height) controlPoint2: CGPointMake(minX + 0.05665 * width, minY + 0.48680 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.41426 * width, minY + 0.91850 * height) controlPoint1: CGPointMake(minX + 0.14496 * width, minY + 0.65073 * height) controlPoint2: CGPointMake(minX + 0.41426 * width, minY + 0.91850 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.49821 * width, minY + 0.97852 * height) controlPoint1: CGPointMake(minX + 0.43805 * width, minY + 0.94916 * height) controlPoint2: CGPointMake(minX + 0.46635 * width, minY + 0.97852 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.58652 * width, minY + 0.92389 * height) controlPoint1: CGPointMake(minX + 0.52836 * width, minY + 0.97852 * height) controlPoint2: CGPointMake(minX + 0.56305 * width, minY + 0.95176 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.89562 * width, minY + 0.59610 * height) controlPoint1: CGPointMake(minX + 0.58652 * width, minY + 0.92389 * height) controlPoint2: CGPointMake(minX + 0.84464 * width, minY + 0.65763 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.98333 * width, minY + 0.31515 * height) controlPoint1: CGPointMake(minX + 0.96375 * width, minY + 0.51386 * height) controlPoint2: CGPointMake(minX + 0.98333 * width, minY + 0.39165 * height)];
        [bezier4Path addCurveToPoint: CGPointMake(minX + 0.76398 * width, minY + 0.00497 * height) controlPoint1: CGPointMake(minX + 0.98333 * width, minY + 0.13722 * height) controlPoint2: CGPointMake(minX + 0.90781 * width, minY + 0.00497 * height)];
        [bezier4Path closePath];
        bezier4Path.usesEvenOddFillRule = YES;
        
        [fillColor setFill];
        [bezier4Path fill];
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    UIGraphicsPopContext();
    
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [self drawInContext:ctx];
}

@end


@implementation BarelyFullHeart

-(void)drawInContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    
    CGRect frame = self.bounds;
    
    UIColor* fillColor3 = [UIColor colorWithRed: 0.894 green: 0 blue: 0.185 alpha: 0.5];
    
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48387 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52174 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.12903 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26087 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30967 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52174 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.12903 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40452 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27983 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12206 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.12903 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20923 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19355 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08696 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48584 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34675 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45889 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19492 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45629 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28115 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51156 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34861 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.49386 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36447 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.50288 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36528 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74433 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12206 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.54503 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28425 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.61187 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12206 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26087 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.86407 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.12206 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.83871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26087 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48387 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52174 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.83871 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.40452 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.65807 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52174 * CGRectGetHeight(frame))];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76398 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50473 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18662 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.65718 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.54691 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07395 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49113 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18604 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.50235 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19306 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.49367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19267 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26260 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45033 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07945 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.36428 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31442 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.12171 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14009 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.06825 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50917 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38832 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.05665 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48680 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91850 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.14496 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65073 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.41426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91850 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49821 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97852 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.43805 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94916 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.46635 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97852 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58652 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92389 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52836 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97852 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.56305 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95176 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89562 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59610 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.58652 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92389 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.84464 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65763 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31515 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.96375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51386 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.98333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39165 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76398 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.98333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13722 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.90781 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame))];
    [bezier4Path closePath];
    
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor3 setFill];
    [bezier4Path fill];
    
    
    UIGraphicsPopContext();
    
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [self drawInContext:ctx];
}

@end

@implementation AlmostFullHeart

-(void)drawInContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    
    CGRect frame = self.bounds;
    
    //// Color Declarations
    UIColor* fillColor3 = [UIColor colorWithRed: 0.894 green: 0 blue: 0.185 alpha: 1];
    
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48387 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39130 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26087 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.48387 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39130 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.06452 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34783 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48584 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34675 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.19608 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22961 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45629 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28115 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51156 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34861 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.49386 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36447 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.50288 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36528 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.80645 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26087 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.54503 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28425 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.80645 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26087 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48387 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39130 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.93548 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34783 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.48387 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39130 * CGRectGetHeight(frame))];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76398 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50473 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18662 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.65718 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.54691 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07395 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49113 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18604 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.50235 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19306 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.49367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19267 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26260 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.45033 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07945 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.36428 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31442 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.12171 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14009 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.06825 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50917 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38832 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.05665 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48680 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91850 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.14496 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65073 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.41426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91850 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49821 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97852 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.43805 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94916 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.46635 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97852 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58652 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92389 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52836 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97852 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.56305 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95176 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89562 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59610 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.58652 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92389 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.84464 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65763 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31515 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.96375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51386 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.98333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39165 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76398 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.98333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13722 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.90781 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00497 * CGRectGetHeight(frame))];
    [bezier4Path closePath];
    
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor3 setFill];
    [bezier4Path fill];
    
    
    UIGraphicsPopContext();
    
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [self drawInContext:ctx];
}

@end

