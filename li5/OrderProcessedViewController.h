//
//  OrderSuccessViewController.h
//  li5
//
//  Created by gustavo hansen on 10/17/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardUIView.h"
#import "ProductPageProtocol.h"

@interface OrderProcessedViewController : UIViewController<DisplayableProtocol, CardUIViewDelegate>

@property (nonatomic, strong) Order *order;
@property (nonatomic, strong) UIViewController *parent;

@end
