//
//  ShippingInfoViewController.h
//  li5
//
//  Created by Martin Cocaro on 7/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import MapKit;
@import Stripe;

#import "ProductPageProtocol.h"

@interface ShippingInfoViewController : UIViewController<MKMapViewDelegate, UITextFieldDelegate,DisplayableProtocol>

-(void) setIsBillingAddress:(BOOL)value;
-(void) setCreditCardParams:(STPCardParams *) value;
-(void) setShowSameAsBillingAddress:(BOOL)value;
@end
