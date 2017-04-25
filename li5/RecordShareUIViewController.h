//
//  RecordShareUIViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/24/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

@import Li5Api;

#import "RecordingFeature.h"
#import "ShareFeature.h"

@interface RecordShareUIViewController : UIViewController

@property (strong,nonatomic) RecordingFeature *recording;
@property (nonatomic,strong) ShareFeature* share;

@end
