//
//  AddShippingInfoViewController.h
//  li5
//
//  Created by gustavo hansen on 10/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Stripe;

#import "Address.h"
#import <UIKit/UIKit.h>

@interface AddShippingInfoViewController : UIViewController

-(void) setCreditCardParams:(STPCardParams *) value;
-(void) setCreditCardAlias:(NSString *)value;
-(void) setCurrentAddress:(Address *)address;
@end
