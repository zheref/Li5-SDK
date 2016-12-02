//
//  ViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import AVFoundation;
@import BCVideoPlayer;

#import "ProductPageProtocol.h"
#import "Li5-Swift.h"

@interface TeaserViewController : UIViewController <UIGestureRecognizerDelegate, DisplayableProtocol, BCPlayerDelegate, TapAndHoldViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIViewController *previousViewController;
@property (nonatomic, strong) UIViewController *nextViewController;

+ (id)teaserWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx;

- (void)setPriority:(BCPriority)priority;

- (BCPlayer *) getPlayer;

@end

