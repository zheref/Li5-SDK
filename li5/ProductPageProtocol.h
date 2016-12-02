//
//  DisplayableProtocol.h
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import Li5Api;

typedef NS_ENUM(NSUInteger, ProductContext) {
    kProductContextDiscover=0,
    kProductContextSearch=1
};

@protocol LinkedViewControllerProtocol <NSObject>

@required

@property (nonatomic, weak) UIViewController *previousViewController;
@property (nonatomic, weak) UIViewController *nextViewController;

@end

@protocol DisplayableProtocol <NSObject>

@required

@property (nonatomic, strong) Product *product;

@optional

- (id)initWithProduct:(Product *)thisProduct andContext:(ProductContext) ctx;

@end
