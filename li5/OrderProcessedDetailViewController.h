//
//  OrderProcessedDetailViewController.h
//  li5
//
//  Created by gustavo hansen on 11/24/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardUIView.h"
#import "Order.h"

@interface OrderProcessedDetailViewController : UIViewController<CardUIViewDelegate>

@property (nonatomic, strong) Order *order;

@end
