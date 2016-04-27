//
//  VideoViewController.h
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductPageProtocol.h"

@interface VideoViewController : UIViewController <LinkedViewControllerProtocol, DisplayableProtocol, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController *previousViewController;
@property (nonatomic, strong) UIViewController *nextViewController;

@property (nonatomic, strong) Product *product;

@end
