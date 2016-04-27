//
//  ViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductPageProtocol.h"
#import "Li5ApiHandler.h"
#import "Li5Player.h"

@import AVFoundation;

@interface TeaserViewController : UIViewController <UIGestureRecognizerDelegate, Li5PlayerDelegate, DisplayableProtocol>

@property (nonatomic, strong) Product *product;

@property (nonatomic, strong) UIViewController *previousViewController;
@property (nonatomic, strong) UIViewController *nextViewController;

- (id) initWithProduct:(Product *)thisProduct;

@end

