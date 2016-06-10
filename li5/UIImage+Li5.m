//
//  UIImage+Li5.m
//  li5
//
//  Created by Martin Cocaro on 5/28/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "UIImage+Li5.h"

@implementation UIImage (Li5)

+ (UIImage*) imageWithColor:(UIColor*)color andRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)roundedImage
{
    CGRect rect = CGRectMake(0, 0,self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, false, 1);
    [[UIBezierPath
     bezierPathWithRoundedRect:rect
      cornerRadius:self.size.height] addClip];
    [self drawInRect:rect];
    return UIGraphicsGetImageFromCurrentImageContext();
}

@end
