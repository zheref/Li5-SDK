//
//  UIViewController+Indexed.h
//  li5
//
//  Created by Martin Cocaro on 6/25/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Indexed)

@property (nonatomic, assign) NSInteger scrollPageIndex;

- (UIViewController*)topMostViewController;

@end
