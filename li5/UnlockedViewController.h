//
//  UnlockedViewController.h
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5ApiHandler.h"
#import "ProductPageProtocol.h"

@interface UnlockedViewController : UIViewController <UIGestureRecognizerDelegate, Li5PlayerDelegate, DisplayableProtocol>

@property (nonatomic, strong) Product *product;

- (id) initWithProduct:(Product *) thisProduct;

@end
