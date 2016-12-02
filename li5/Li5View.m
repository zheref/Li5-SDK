//
//  Li5View.m
//  li5
//
//  Created by Martin Cocaro on 5/21/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "Li5View.h"

@interface Li5View ()

@property (nonatomic, strong) IBOutlet UIView *view;

@end

@implementation Li5View

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
    [self setupFromXib];
}

#pragma mark - UI Setup

- (void)setupFromXib
{
    if (!self.view)
    {
        NSString *xibName = self.xibName ?: NSStringFromClass(self.class);
        self.view = [[[NSBundle bundleForClass:self.class] loadNibNamed:xibName owner:self options:nil] firstObject];
        [self addSubview:self.view];

        [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(_view);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_view]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_view]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
    }
}

- (UIViewController *)parentViewController
{
    UIResponder *responder = self;
    while ([responder isKindOfClass:[UIView class]])
        responder = [responder nextResponder];
    return (UIViewController *)responder;
}

@end
