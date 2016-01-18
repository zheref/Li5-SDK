//
//  LinkedViewController.h
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Logger.h"
#import "DisplayableProtocol.h"

@interface LinkedViewController : UIViewController

@property (nonatomic, strong) UIViewController *previousViewController;
@property (nonatomic, strong) UIViewController *nextViewController;

@end
