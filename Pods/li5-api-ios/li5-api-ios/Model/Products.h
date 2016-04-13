//
//  Products.h
//  li5-api-ios
//
//  Created by Leandro Fournier on 4/14/16.
//  Copyright © 2016 Leandro Fournier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "Product.h"

@interface Products : JSONModel

@property (nonatomic, strong) NSArray <Product> *data;

@end
