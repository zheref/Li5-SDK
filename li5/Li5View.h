//
//  Li5View.h
//  li5
//
//  Created by Martin Cocaro on 5/21/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Li5View : UIView

@property (nonatomic, strong) NSString *xibName;

- (void)initialize;
- (UIViewController *)parentViewController;

@end
