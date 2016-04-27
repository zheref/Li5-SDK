//
//  Li5PlayerUISlider.h
//  li5
//
//  Created by Martin Cocaro on 4/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface Li5PlayerUISlider : UISlider

- (void)setPlayer:(AVPlayer *)aPlayer;

- (void)sliderGestureRecognized:(id)sender;

- (instancetype)initWithFrame:(CGRect)frame andPlayer:(AVPlayer*) aPlayer;

@end