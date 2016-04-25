//
//  Product.h
//  li5-api-ios
//
//  Created by Leandro Fournier on 4/14/16.
//  Copyright © 2016 Leandro Fournier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface Product : JSONModel

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSArray <NSString *> *images;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *updated_at;
@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *categoryImage;
@property (nonatomic, strong) NSNumber<Optional> *videoDuration;
@property (nonatomic, strong) NSDictionary<Optional> *videoMetadata;
@property (nonatomic, strong) NSString<Optional> *videoPreview;
@property (nonatomic, strong) NSString<Optional> *trailerDuration;
@property (nonatomic, strong) NSDictionary<Optional> *trailerMetadata;
@property (nonatomic, strong) NSString<Optional> *trailerURL;
@property (nonatomic, strong) NSString<Optional> *videoURL;

@end

@protocol Product @end