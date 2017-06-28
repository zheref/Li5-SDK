//
//  SliderFluidView.m
//  li5
//
//  Created by Martin Cocaro on 7/4/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "SliderFluidView.h"

@implementation SliderFluidView

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
        [self animateSlider];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    CGRect rotatedFrame = CGRectMake(self.frame.origin.y, self.frame.origin.x, self.frame.size.height, self.frame.size.width);
    // We make the frame rotated because BAFluidView animates vertically
    self.fluidView = [[BAFluidView alloc] initWithFrame:rotatedFrame];
}

- (void)animateSlider {
    self.fluidView.fillAutoReverse = NO;
    self.fluidView.fillRepeatCount = 1;
    self.fluidView.maxAmplitude = 50;
    self.fluidView.minAmplitude = 20;
    
    // line color
    self.fluidView.strokeColor = [UIColor yellowColor];
    
    // fill color
    self.fluidView.fillColor = [UIColor yellowColor];
    // We rotate the frame to make the animation horizontally
    self.fluidView.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.fluidView.frame = self.bounds;
    [self addSubview:self.fluidView];
    
    [self.fluidView fillTo:@0.001];
    
}


@end
