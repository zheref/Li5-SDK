//
//  Li5PlayerTimer.h
//  li5
//
//  Created by Martin Cocaro on 6/2/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import AVFoundation;

//IB_DESIGNABLE
@interface Li5PlayerTimer : UIView

@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, assign) BOOL hasUnlocked;
@property (nonatomic, assign) CGFloat percentage;

@end
