//
//  CardUICollectionViewCell.m
//  li5
//
//  Created by Martin Cocaro on 6/17/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "CardUICollectionViewCell.h"

@implementation CardUICollectionViewCell

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    CGPoint center = layoutAttributes.center;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.toValue = @(center.y);
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.8 :2.0 :1.0 :1.0];
    
    [self.layer addAnimation:animation forKey:@"position.y"];
    
    [super applyLayoutAttributes:layoutAttributes];
}

@end
