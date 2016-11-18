//
//  DetailsDescriptionViewController.m
//  li5
//
//  Created by Martin Cocaro on 6/20/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "DetailsDescriptionViewController.h"
#import "CardUIView.h"

@interface DetailsDescriptionViewController ()

@property (weak, nonatomic) IBOutlet CardUIView *cardView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DetailsDescriptionViewController

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
    
}

#pragma mark - UI Setup

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.5];
    
    [self __refreshView];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    [self.textView flashScrollIndicators];
}

- (void)__refreshView
{
    DDLogVerbose(@"");
    [self.textView setText:self.product.body];
}

- (void)setProduct:(Product *)product
{
    DDLogVerbose(@"");
    _product = product;
    
    if ([self isViewLoaded])
    {
        [self __refreshView];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touch = [gestureRecognizer locationInView:gestureRecognizer.view];
    return !CGRectContainsPoint(self.cardView.frame, touch);
}

- (IBAction)tapOutsideCard:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
