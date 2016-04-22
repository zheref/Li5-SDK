//
//  Li5Player.h
//  li5
//
//  Created by Leandro Fournier on 3/31/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class Li5Player;

@protocol Li5PlayerDelegate

- (void)li5Player:(Li5Player *)li5Player changedStatusForPlayerItem:(AVPlayerItem *)playerItem withStatus:(AVPlayerItemStatus)status;
- (void)li5Player:(Li5Player *)li5Player updatedLoadedSecondsForPlayerItem:(AVPlayerItem *)playerItem withSeconds:(CGFloat)seconds;

@end

@interface Li5Player : AVPlayer

@property (nonatomic, strong) id <Li5PlayerDelegate> delegate;

- (id)initWithItemAtURL:(NSURL *)url;

@end
