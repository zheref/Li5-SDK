//
//  RecordUIButton.h
//  li5
//
//  Created by Martin Cocaro on 1/24/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface RecordUIButton : UIView

@property (nonatomic, copy) void (^onRecord)();
@property (nonatomic, copy) void (^onDoneRecording)();
@property (nonatomic, copy) void (^onCancelRecording)();

- (void)setProgress:(CGFloat)newProgress;

@end

@interface TouchDetector : UIGestureRecognizer

@end
