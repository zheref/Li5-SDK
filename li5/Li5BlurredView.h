//
//  Li5BlurredView.h
//  li5
//
//  Created by Martin Cocaro on 6/1/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface Li5BlurredView : UIView

@property (nonatomic, assign) IBInspectable CGFloat blurSize;
@property (nonatomic, assign) IBInspectable NSInteger style;

@end
