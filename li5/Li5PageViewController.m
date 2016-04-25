//
//  Li5PageViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/20/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5PageViewController.h"

@interface Li5PageViewController () {
    UIPanGestureRecognizer *_scrollViewPanGestureRecognzier;
}

@end

@implementation Li5PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            scrollView.delaysContentTouches = false;
            _scrollViewPanGestureRecognzier = [[UIPanGestureRecognizer alloc] init];
            _scrollViewPanGestureRecognzier.delegate = self;
            [scrollView addGestureRecognizer:_scrollViewPanGestureRecognzier];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _scrollViewPanGestureRecognzier)
    {
        CGPoint locationInView = [gestureRecognizer locationInView:self.view];
        if (locationInView.y < 100) {
            return YES;
        }
        return NO;
    }
    return NO;
}

@end
