//
//  ProductPageActionsView.h
//  li5
//
//  Created by Martin Cocaro on 6/5/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import Li5Api;

#import "Li5View.h"
#import "Li5-Swift.h"

//IB_DESIGNABLE
@interface ProductPageActionsView : Li5View<HeartAnimationViewDelegate>

- (void)setProduct:(Product *)product isEligibleForMultiLevel:(BOOL)isEligibleForMultiLevel;
- (void)refreshStatus;
- (void)animate;

@end

@interface UIActivityViewController (Private)

- (BOOL)_shouldExcludeActivityType:(UIActivity*)activity;

@end

@interface ActivityViewController : UIActivityViewController

@end
