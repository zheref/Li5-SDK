//
//  Li5GradientView.m
//  li5
//
//  Created by Martin Cocaro on 6/1/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5GradientView.h"

@interface Li5GradientView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation Li5GradientView

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
    [self addSubviews];
}

#pragma mark - UI Setup

- (void)addSubviews
{
    _topColor = [UIColor clearColor];
    _bottomColor = [UIColor blackColor];
    
    // Create the gradient
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.colors = @[(id)_topColor.CGColor, (id)_bottomColor.CGColor];
    _gradientLayer.frame = self.bounds;
    
    //Add gradient to view
    [self.layer insertSublayer:_gradientLayer atIndex:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _gradientLayer.bounds = self.bounds;
}

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    [self addSubviews];
}

#pragma mark - Public Methods

- (void)setTopColor:(UIColor *)topColor
{
    _topColor = topColor;
    _gradientLayer.colors = @[(id)_topColor.CGColor, (id)_bottomColor.CGColor];
}

- (void)setBottomColor:(UIColor *)bottomColor
{
    _bottomColor = bottomColor;
    _gradientLayer.colors = @[(id)_topColor.CGColor, (id)_bottomColor.CGColor];
}

@end
