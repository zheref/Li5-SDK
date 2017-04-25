//
//  ShapesHelper.h
//  li5
//
//  Created by Martin Cocaro on 1/28/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@interface ShapesHelper : UIView

+ (UIBezierPath *)heartShape:(CGRect)originalFrame;
+ (UIBezierPath *)userShape:(CGRect)originalFrame;
+ (UIBezierPath *)martiniShape:(CGRect)originalFrame;
+ (UIBezierPath *)beakerShape:(CGRect)originalFrame;
+ (UIBezierPath *)starShape:(CGRect)originalFrame;
+ (UIBezierPath *)stars:(NSUInteger)numberOfStars shapeInFrame:(CGRect)originalFrame;
+ (UIBezierPath *)hexagonWithWidth:(NSUInteger)width andHeight:(NSUInteger)height;
+ (UIBezierPath *)rectangleWithWidth:(NSUInteger)width andHeight:(NSUInteger)height;
+ (UIBezierPath *)lineWithWidth:(NSUInteger)width;
+ (UIBezierPath *)drawRightArrowWithFrame: (CGRect)frame;

@end
