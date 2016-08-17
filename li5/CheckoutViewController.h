//
//  CheckoutViewController.h
//  li5
//
//  Created by Martin Cocaro on 7/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "CardIO.h"
#import "ProductPageProtocol.h"

@interface CheckoutViewController : UIViewController<CardIOPaymentViewControllerDelegate, UITextFieldDelegate,DisplayableProtocol>

@end
