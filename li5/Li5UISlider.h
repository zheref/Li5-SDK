//
//  Li5UISlider.h
//  li5
//
//  Created by Martin Cocaro on 4/24/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@protocol Li5SliderDelegate;

@interface Li5UISlider : UISlider

@property (weak, nonatomic) id<Li5SliderDelegate> delegate;

@end

@protocol Li5SliderDelegate <NSObject>

@optional

- (void)tapSlider:(Li5UISlider *)tapSlider valueDidChange:(float)value;

@end

