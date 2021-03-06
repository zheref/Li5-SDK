//
//  UIViewController+Indexed.m
//  li5
//
//  Created by Martin Cocaro on 6/25/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "UIViewController+Indexed.h"
#import <objc/runtime.h>

@implementation UIViewController (Indexed)

- (void)setScrollPageIndex:(NSInteger)idx
{
    objc_setAssociatedObject(self, @selector(scrollPageIndex), [NSNumber numberWithInteger:idx], OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)scrollPageIndex
{
    return [objc_getAssociatedObject(self, @selector(scrollPageIndex)) integerValue];
}

- (UIViewController*)topMostViewController
{
    UIViewController *topController = self;
    BOOL stop = NO;
    
    while (topController.presentedViewController && !stop) {
        stop = topController.presentedViewController.modalPresentationStyle == UIModalPresentationOverCurrentContext || topController.presentedViewController.modalPresentationStyle == UIModalPresentationPopover;
        if (!stop) {
            topController = topController.presentedViewController;
        }
    }
    
    return topController;
}

@end
