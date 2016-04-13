//
//  Category.h
//  li5-api-ios
//
//  Created by Leandro Fournier on 4/14/16.
//  Copyright © 2016 Leandro Fournier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface Category : JSONModel

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *image;

@end

@protocol Category @end