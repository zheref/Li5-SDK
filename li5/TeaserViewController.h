//
//  ViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import AVFoundation;
@import BCVideoPlayer;

#import "ProductPageProtocol.h"

@interface TeaserViewController : UIViewController <UIGestureRecognizerDelegate, DisplayableProtocol, BCPlayerDelegate>

@property (nonatomic, strong) UIViewController *previousViewController;
@property (nonatomic, strong) UIViewController *nextViewController;

+ (id)teaserWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx;

@end

