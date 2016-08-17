//
//  OrderProcessedViewController.h
//  li5
//
//  Created by Martin Cocaro on 7/28/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ProductPageProtocol.h"

@interface OrderProcessedViewController : UIViewController <DisplayableProtocol>

@property (nonatomic, strong) Order *order;

@end
