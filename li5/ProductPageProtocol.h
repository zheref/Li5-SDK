//
//  DisplayableProtocol.h
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5ApiHandler.h"

@protocol LinkedViewControllerProtocol <NSObject>

@required

@property (nonatomic, strong) UIViewController *previousViewController;
@property (nonatomic, strong) UIViewController *nextViewController;

@end

@protocol DisplayableProtocol <NSObject>

@required

@property (nonatomic, strong) Product *product;

- (void)hideAndMoveToViewController:(UIViewController *)viewController;
- (void)show;
- (void)redisplay;

@optional

- (id)initWithProduct:(Product *)thisProduct;

@end
