//
//  Li5GradientView.h
//  li5
//
//  Created by Martin Cocaro on 6/1/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface Li5GradientView : UIView

@property (nonatomic, strong) IBInspectable UIColor *topColor;
@property (nonatomic, strong) IBInspectable UIColor *bottomColor;

@end
