//
//  Product.h
//  li5
//
//  Created by Martin Cocaro on 1/29/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Logger.h"
#import <Parse/Parse.h>

@interface Product : PFObject <PFSubclassing>

//Dynamic properties
@property (nonatomic, weak) NSString *video;
@property (nonatomic, weak) NSArray<NSString*> *images;
@property (nonatomic, weak) NSString *title;
@property (nonatomic, weak) NSString *vendor;
@property (nonatomic, weak) NSString *price;
@property (nonatomic, weak) NSString *desc;
@property (nonatomic, weak) NSString *cta;
@property (nonatomic, weak) NSString *still;
@property (nonatomic, weak) NSString *displayed_at;
@property (nonatomic, weak) NSString *category;
@property (nonatomic, weak) NSNumber *teaser_duration;

@end
