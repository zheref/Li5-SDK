//
//  UIBezierPath+UIImage.m
//  li5
//
//  Created by Martin Cocaro on 6/30/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "UIBezierPath+UIImage.h"

@implementation UIBezierPath (UIImage)

- (UIImage *)imageWithStrokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    CGRect bounds = self.bounds;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width + self.lineWidth * 2, bounds.size.width + self.lineWidth * 2),false,[UIScreen mainScreen].scale);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // offset the draw to allow the line thickness to not get clipped
    CGContextTranslateCTM(context, self.lineWidth, self.lineWidth);

    if (!strokeColor)
    {
        strokeColor = fillColor;
    }
    else if (!fillColor)
    {
        fillColor = strokeColor;
    }

    [strokeColor setStroke];
    [fillColor setFill];

    [self fill];
    [self stroke];

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return result;
}

@end
