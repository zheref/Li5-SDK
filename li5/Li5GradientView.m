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
    _topColor = [UIColor blackColor];
    _bottomColor = [UIColor clearColor];
    
    [self addSubviews];
}

#pragma mark - UI Setup

- (void)addSubviews
{
    // Create the gradient
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.locations = @[@0.5, @1.0];
    _gradientLayer.colors = @[(id)_topColor.CGColor, (id)_bottomColor.CGColor];
    
    //Add gradient to view
    [self.layer insertSublayer:_gradientLayer atIndex:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _gradientLayer.frame = self.bounds;
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
    
    [self layoutSubviews];
}

- (void)setBottomColor:(UIColor *)bottomColor
{
    _bottomColor = bottomColor;
    _gradientLayer.colors = @[(id)_topColor.CGColor, (id)_bottomColor.CGColor];
    
    [self layoutSubviews];
}

@end
