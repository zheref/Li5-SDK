//
//  VideoViewController.h
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import BCVideoPlayer;

#import "ProductPageProtocol.h"

@interface VideoViewController : UIViewController <DisplayableProtocol, UIGestureRecognizerDelegate>

- (void)setPriority:(BCPriority)priority;

- (BCPlayer *)getPlayer;

@end
