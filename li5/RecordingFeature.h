//
//  RecordingFeature.h
//  li5
//
//  Created by Martin Cocaro on 1/30/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

@import SCRecorder;

#import <Foundation/Foundation.h>

@interface RecordingFeature : NSObject

@property (nonatomic, copy) void (^onExportFinished)(NSURL* path, NSError *error);

@property (weak,nonatomic) UIView *previewView;

- (SCRecorderToolsView*)activateFocusView;
- (SCVideoPlayerView*)activatePlayerView:(UIView*)playerView;
- (SCRecordSession*)prepareSession;
- (SCRecorder*)recorder;

- (void)layoutSubviews;
- (void)startRecording;
- (void)pauseRecording:(void(^)())completionHandler;
- (void)cancel;
- (void)stopRecording;
- (void)record;
- (void)export;
- (void)play;
- (void)pause;

@end
