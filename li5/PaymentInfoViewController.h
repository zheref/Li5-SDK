//
//  CreditInformationViewController.h
//  li5
//
//  Created by gustavo hansen on 10/17/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "CardIO.h"
#import "ProductPageProtocol.h"

@interface PaymentInfoViewController : UIViewController<CardIOPaymentViewControllerDelegate, UITextFieldDelegate>

- (void) setCurrentCard:(Card *) card;
@end
