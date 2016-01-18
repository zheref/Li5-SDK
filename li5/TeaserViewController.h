//
//  ViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Logger.h"

#import "LinkedViewController.h"
#import "Product.h"

@import AVFoundation;

@interface TeaserViewController : LinkedViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong) AVPlayerLayer *_playerLayer;
@property (nonatomic, weak) Product *product;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CATextLayer *timeText;
@property (nonatomic, strong) NSMutableArray<CALayer*> *removableItems;

@property BOOL unlocked;
@property BOOL rendered;
@property BOOL hidden;

- (id) initWithProduct:(Product *) thisProduct;

- (void)handleTap:(UITapGestureRecognizer *)sender;
- (void)handleLongTap:(UITapGestureRecognizer *)sender;

@end

