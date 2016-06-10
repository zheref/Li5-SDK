//
//  Li5BlurredView.m
//  li5
//
//  Created by Martin Cocaro on 6/1/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5BlurredView.h"

@interface Li5BlurredView ()

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIVisualEffectView *vibrantEffectView;

@end

@implementation Li5BlurredView

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
    _style = _style ? : UIBlurEffectStyleDark;
    
    [self addSubviews];
}

- (void)addSubviews
{
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        if (!_blurEffectView && !_vibrantEffectView)
        {
            [_blurEffectView removeFromSuperview];
            [_vibrantEffectView removeFromSuperview];
        }
        
        //create blur effect
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:self.style];
        // create vibrancy effect
        UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurEffectView.frame = self.bounds;
        _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // add vibrancy to yet another effect view
        _vibrantEffectView = [[UIVisualEffectView alloc]initWithEffect:vibrancy];
        _vibrantEffectView.frame = self.bounds;
        
        [self addSubview:_blurEffectView];
        [self addSubview:_vibrantEffectView];
    }
    else {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.alpha];
    }
}

#pragma mark - UI Setup

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    [self initialize];
}

#pragma mark - Public Methods

- (void)setStyle:(NSInteger)style
{
    _style = style ? : UIBlurEffectStyleDark;
    [self addSubviews];
}

@end
