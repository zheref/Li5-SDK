//
//  RecordShareUIViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/24/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

@import AMPopTip;

#import "RecordShareUIViewController.h"
#import "RecordUIButton.h"
#import "PreviewRecordingUIViewController.h"

@interface RecordShareUIViewController () 

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet RecordUIButton *recordButton;
@property (nonatomic, weak) UIViewController *_parentViewController;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) AMPopTip *popTip;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end

@implementation RecordShareUIViewController

#pragma mark - UI Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _recording = [RecordingFeature new];
    [_recording setPreviewView:self.previewView];
    [_recording activateFocusView];
        
    __weak typeof(self) welf = self;
    [self.recordButton setOnRecord:^{
        [welf hideAllControls];
        [welf.recording record];
        [welf setupTimers];
    }];
    [self.recordButton setOnDoneRecording:^{
        [welf showAllControls];
        [welf removeTimers];
        [welf.recording pauseRecording:^{
            [welf showVideo];
        }];
    }];
    [self.recordButton setOnCancelRecording:^{
        [welf showAllControls];
        [welf.recording cancel];
    }];
    
    __parentViewController = self.presentingViewController;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.recording layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.recording prepareSession];
    
    [self.recording startRecording];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self presentPopOverExplainer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.recording stopRecording];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - NSTimers

- (void)setupTimers {
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
}

- (void)removeTimers {
    if (self.progressTimer) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
}

- (void)updateProgress:(NSTimer*)timer {
    double progress = CMTimeGetSeconds(self.recording.recorder.session.duration) / 10.0;
    DDLogVerbose(@"%f",progress);
    [self.recordButton setProgress:progress];
}

#pragma mark - User Actions

- (IBAction)didTapBackButton:(id)sender {
    [self.recording cancel];
    
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}

- (IBAction)didTapShareButton:(id)sender {

    __weak typeof(self) welf = self;
    [self.share present:self completion:^(NSError *error, BOOL cancelled) {
        [welf dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - Private Methods

- (void)presentPopOverExplainer {
    
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.entranceAnimation = AMPopTipEntranceAnimationScale;
    self.popTip.actionAnimation = AMPopTipActionAnimationBounce;
    
    AMPopTip *appearance = [AMPopTip appearance];
    appearance.popoverColor = [UIColor li5_redColor];
    
    [self.popTip showText:NSLocalizedString(@"Record a private message to your friends and pass it along your share!",nil) direction:AMPopTipDirectionUp maxWidth:self.view.frame.size.width - 100 inView:self.view fromFrame:self.recordButton.frame duration:10.0];
}

- (void)showVideo {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle mainBundle]];
    PreviewRecordingUIViewController *previewRecordingView = (PreviewRecordingUIViewController*)[storyboard instantiateViewControllerWithIdentifier:@"PreviewRecordingView"];
    previewRecordingView.recording = self.recording;
    previewRecordingView.share = self.share;
    
    [self.navigationController pushViewController:previewRecordingView animated:NO];
}

- (void)hideAllControls {
    [self.popTip hide];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.shareButton.alpha = 0.0;
        self.backButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        //DO NOTHING for now
    }];
}

- (void)showAllControls {
    [UIView animateWithDuration:0.3 animations:^{
        self.shareButton.alpha = 1.0;
        self.backButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        //DO NOTHING for now
    }];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    DDLogVerbose(@"%p",self);
}

@end
