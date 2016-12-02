//
//  UIImage+Li5.h
//  li5
//
//  Created by Martin Cocaro on 5/28/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Li5)

+ (UIImage*) imageWithColor:(UIColor*)color andRect:(CGRect)rect;

- (UIImage*)roundedImage;

- (UIImage *)blackAndWhiteImage;

@end
