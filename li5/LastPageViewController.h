//
//  LastPageViewController.h
//  li5
//
//  Created by Leandro Fournier on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import BCVideoPlayer;
@import AVFoundation;

#import "ProductPageProtocol.h"
#import "ProductPageViewController.h"

@interface LastPageViewController : ProductPageViewController <UIGestureRecognizerDelegate,DisplayableProtocol, BCPlayerDelegate>

@property (nonatomic, strong) EndOfPrimeTime *lastVideoURL;

@end
