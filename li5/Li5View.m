//
//  Li5View.m
//  li5
//
//  Created by Martin Cocaro on 5/21/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5View.h"

@interface Li5View ()

@property (nonatomic, strong) IBOutlet UIView *view;

@end

@implementation Li5View

- (instancetype)init
{
    DDLogDebug(@"");
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    DDLogDebug(@"");
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    DDLogDebug(@"");
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    DDLogDebug(@"");
    [self setupFromXib];
}

- (void)setupFromXib
{
    DDLogDebug(@"");
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

@end