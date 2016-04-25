//
//  Product.m
//  li5-api-ios
//
//  Created by Leandro Fournier on 4/14/16.
//  Copyright © 2016 Leandro Fournier. All rights reserved.
//

#import "Product.h"

@implementation Product

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"body": @"body",
                                                       @"brand": @"brand",
                                                       @"created_at": @"created_at",
                                                       @"id": @"id",
                                                       @"images": @"images",
                                                       @"price": @"price",
                                                       @"title": @"title",
                                                       @"updated_at": @"updated_at",
                                                       @"category.data.id": @"categoryId",
                                                       @"category.data.name": @"categoryName",
                                                       @"category.data.image": @"categoryImage",
                                                       @"video.duration": @"videoDuration",
                                                       @"video.metadata": @"videoMetadata",
                                                       @"video.preview": @"videoPreview",
                                                       @"video.trailer.duration": @"trailerDuration",
                                                       @"video.trailer.metadata": @"trailerMetadata",
                                                       @"video.trailer.url": @"trailerURL",
                                                       @"video.url": @"videoURL"
                                                       }];
}


@end
