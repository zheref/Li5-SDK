//
//  UnlockedViewController.h
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import AVFoundation;
@import BCVideoPlayer;

#import "ProductPageProtocol.h"

@interface UnlockedViewController : UIViewController <UIGestureRecognizerDelegate, DisplayableProtocol, BCPlayerDelegate, UIActionSheetDelegate>

@property(nonatomic, assign) CGPoint initialPoint;

+ (id)unlockedWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx;

@end
