//
//  Li5Player.m
//  li5
//
//  Created by Leandro Fournier on 3/31/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5Player.h"
#import "Logger.h"

@implementation Li5Player

- (id)initWithItemAtURL:(NSURL *)url {
    if (self = [super init]) {
        AVPlayerItem *playerItem = [self playerItemWithURL:url];
        [self replaceCurrentItemWithPlayerItem:playerItem];
    }
    return self;
}

- (AVPlayerItem *)playerItemWithURL:(NSURL *)url {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidFailedToPlayToEnd:) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:playerItem];
    return playerItem;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        
        if ([keyPath isEqualToString:@"status"]) {
            [self.delegate li5Player:self changedStatusForPlayerItem:self.currentItem withStatus:self.currentItem.status];
            return;
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSValue *timeRageValue = [[item loadedTimeRanges] firstObject];
            CMTime duration = [timeRageValue CMTimeRangeValue].duration;
            [self.delegate li5Player:self updatedLoadedSecondsForPlayerItem:self.currentItem withSeconds:CMTimeGetSeconds(duration)];
            return;
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            DDLogVerbose(@"Buffer is empty for %@", [(AVURLAsset *)item.asset URL]);
            return;
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            DDLogVerbose(@"Buffer is going well for %@", [(AVURLAsset *)item.asset URL]);
            return;
        }
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)dealloc {
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:nil];
}

#pragma mark - Notifications

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *item = (AVPlayerItem *)notification.object;
    [item seekToTime:kCMTimeZero];
}

- (void)playerItemDidFailedToPlayToEnd:(NSNotification *)notification
{
    NSError *error = notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    DDLogVerbose(@"playerItemDidFailedToPlayToEnd: %@", error.localizedDescription);
}

@end
