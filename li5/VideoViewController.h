//
//  VideoViewController.h
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import BCVideoPlayer;

#import "ProductPageProtocol.h"

@interface VideoViewController : UIViewController <LinkedViewControllerProtocol, DisplayableProtocol, UIGestureRecognizerDelegate>

- (void)setPriority:(BCPriority)priority;

- (BCPlayer *)getPlayer;

@end
