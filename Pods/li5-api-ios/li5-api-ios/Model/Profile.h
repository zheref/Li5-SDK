//
//  Profile.h
//  li5-api-ios
//
//  Created by Leandro Fournier on 4/14/16.
//  Copyright © 2016 Leandro Fournier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "Categories.h"

@interface Profile : JSONModel

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) NSString *updated_at;
@property (nonatomic, strong) Categories *preferences;

@end
