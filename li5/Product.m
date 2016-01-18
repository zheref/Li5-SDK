//
//  Product.m
//  li5
//
//  Created by Martin Cocaro on 1/29/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Product.h"

#import <Parse/PFObject+Subclass.h>

@implementation Product

@dynamic objectId,title, vendor, price, desc, cta, video, images, still, displayed_at, category, teaser_duration;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end
