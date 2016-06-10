//
//  Li5PlayerUISlider.h
//  li5
//
//  Created by Martin Cocaro on 4/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import AVFoundation;

IB_DESIGNABLE
@interface Li5PlayerUISlider : UIView

@property (nonatomic, weak) AVPlayer *player;

- (CGFloat)getProgress;

- (CGFloat)setProgress:(CGFloat)percentage animated:(BOOL)animated;

@end