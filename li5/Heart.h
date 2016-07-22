//
//  Heart.h
//  Heart
//
//  Created by Martin Cocaro on 7/1/16.
//  Copyright (c) 2016 ThriveCom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FullHeart : CALayer
@property(nonatomic, strong) UIColor *foregroundColor;
@end

@interface EmptyHeart : CALayer
@property(nonatomic, strong) UIColor *foregroundColor;
@end

@interface BarelyFullHeart : CALayer
@property(nonatomic, strong) UIColor *foregroundColor;
@end

@interface AlmostFullHeart : CALayer
@property(nonatomic, strong) UIColor *foregroundColor;
@end

