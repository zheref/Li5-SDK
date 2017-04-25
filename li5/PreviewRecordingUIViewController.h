//
//  PreviewRecordingUIViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/26/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

@import Li5Api;

#import "RecordingFeature.h"
#import "ShareFeature.h"

@interface PreviewRecordingUIViewController : UIViewController

@property (nonatomic,weak) RecordingFeature *recording;
@property (nonatomic,weak) ShareFeature* share;

@end
