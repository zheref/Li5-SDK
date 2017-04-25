//
//  RecordingFeature.m
//  li5
//
//  Created by Martin Cocaro on 1/30/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

#import "RecordingFeature.h"

@interface RecordingFeature () <SCRecorderDelegate>

@property (strong, nonatomic) SCRecorder *_recorder;
@property (strong, nonatomic) SCRecorderToolsView *_focusView;
@property (strong, nonatomic) SCPlayer *_player;
@property (strong, nonatomic) SCVideoPlayerView *_videoPlayerView;
@property (strong, nonatomic) SCAssetExportSession *_assetExportSession;

@end

@implementation RecordingFeature

@synthesize previewView = _previewView;

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    __recorder = [SCRecorder recorder];
    __recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    __recorder.maxRecordDuration = CMTimeMake(11,1);
    __recorder.delegate = self;
    __recorder.device = AVCaptureDevicePositionFront;
    __recorder.mirrorOnFrontCamera = YES;
    
    NSError *error;
    if (![__recorder prepare:&error]) {
        DDLogError(@"Prepare error: %@", error.localizedDescription);
    }

    __player = [SCPlayer player];
    __player.loopEnabled = YES;
    
    [self setupObservers];
}

#pragma mark - Public Methods

- (void)layoutSubviews {
    [__recorder previewViewFrameChanged];
}

- (void)setPreviewView:(UIView *)previewView{
    _previewView = previewView;
    __recorder.previewView = _previewView;
}

- (SCRecorderToolsView*)activateFocusView {
    if (!__focusView) {
        __focusView = [[SCRecorderToolsView alloc] initWithFrame:self.previewView.bounds];
        __focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        __focusView.recorder = __recorder;
        __focusView.showsFocusAnimationAutomatically = YES;
//        __focusView.outsideFocusTargetImage = [UIImage imageNamed:@"focus"];
        [self.previewView addSubview:__focusView];
    }
    return __focusView;
}

- (SCVideoPlayerView*)activatePlayerView:(UIView*)playerView {
    if (!__videoPlayerView) {
        __videoPlayerView = [[SCVideoPlayerView alloc] initWithPlayer:__player];
        __videoPlayerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        __videoPlayerView.frame = playerView.frame;
        __videoPlayerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }
    return __videoPlayerView;
}

- (SCRecordSession*)prepareSession {
    //Remove any previous session we had pending if any.
    [self cancel];
    
    SCRecordSession *session = [SCRecordSession recordSession];
    session.fileType = AVFileTypeMPEG4;
    
    __recorder.session = session;
    
    return __recorder.session;
}

- (SCRecorder*)recorder {
    return __recorder;
}

- (void)startRecording {
    [__recorder startRunning];
}

- (void)record {
    [__recorder record];
}

- (void)pauseRecording:(void(^)())completionHandler {
    if (!completionHandler) {
        [__recorder pause];
    } else {
        [__recorder pause:completionHandler];
    }
}

- (void)cancel {
    [__recorder.session cancelSession:^{
        [__recorder.session deinitialize];
    }];
    
    if (__assetExportSession) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *removeError;
        [fileManager removeItemAtURL:__assetExportSession.outputUrl error:&removeError];
        
        [__assetExportSession cancelExport];
    }
}

- (void)stopRecording {
    [__recorder stopRunning];
}

- (void)play {
    [__player setItemByAsset:__recorder.session.assetRepresentingSegments];
    [__player play];
}

- (void)pause {
    [__player pause];
}

- (void)export {
    if (!__assetExportSession || __assetExportSession.progress >= 1.0 || [__assetExportSession cancelled]) {
        __assetExportSession = [[SCAssetExportSession alloc] initWithAsset:__recorder.session.assetRepresentingSegments];
        __assetExportSession.outputUrl = __recorder.session.outputUrl;
        __assetExportSession.outputFileType = AVFileTypeMPEG4;
        __assetExportSession.videoConfiguration.preset = SCPresetMediumQuality;
        __assetExportSession.audioConfiguration.preset = SCPresetMediumQuality;
        __assetExportSession.shouldOptimizeForNetworkUse = YES;
        [__assetExportSession exportAsynchronouslyWithCompletionHandler: ^{
            if (_onExportFinished) {
                _onExportFinished(__recorder.session.outputUrl, __assetExportSession.error);
            }
        }];
    }
}

#pragma mark - SCRecorderDelegate

- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    DDLogVerbose(@"Skipped video buffer");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    DDLogVerbose(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    DDLogVerbose(@"Reconfigured video input: %@", videoInputError);
}

#pragma mark - Observers 

- (void)setupObservers {
    // Subscribe to app events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanDisk)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundCleanDisk)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - App Events

- (void)clearMemory {
    
}

- (void)cleanDisk {
    [self cancel];
}

- (void)backgroundCleanDisk {
    
}

#pragma mark - OS Events

- (void)dealloc {
    [self removeObservers];
}

@end
