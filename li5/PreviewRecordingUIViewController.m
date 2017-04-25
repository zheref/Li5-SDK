//
//  PreviewRecordingUIViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/26/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

#import "PreviewRecordingUIViewController.h"

@interface PreviewRecordingUIViewController ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;

@end

@implementation PreviewRecordingUIViewController

#pragma mark - UI Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SCVideoPlayerView *playerView = [_recording activatePlayerView:self.previewView];
    [self.view insertSubview:playerView aboveSubview:self.previewView];
    
    [self.recording setOnExportFinished:^(NSURL* path, NSError* error) {
        if (error == nil) {
            // We have our video and/or audio file
            DDLogVerbose(@"video export COMPLETE");
        } else {
            // Something bad happened
            DDLogError(@"Error while exporting: %@",error.localizedDescription);
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.recording play];
    
    [self.recording export];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - User Actions

- (IBAction)backButtonPressed:(id)sender {
    [self.recording pause];
    [self.recording cancel];
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)shareButtonPressed:(id)sender {
    __weak typeof(self) welf = self;
    [self.share present:self completion:^(NSError *error, BOOL cancelled) {
        [welf dismissViewControllerAnimated:NO completion:nil];
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
