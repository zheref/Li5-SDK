//
//  ProductPageActionsView.h
//  li5
//
//  Created by Martin Cocaro on 6/5/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import Li5Api;

#import "Li5View.h"

//IB_DESIGNABLE
@interface ProductPageActionsView : Li5View

- (void)setProduct:(Product *)product animate:(BOOL)animate;
- (void)refreshStatus;
- (void)animate;

@end
