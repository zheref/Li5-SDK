//
//  HorizontalUICollectionViewFlowLayout.h
//  li5
//
//  Created by Martin Cocaro on 5/18/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HorizontalUICollectionViewFlowLayout : UICollectionViewFlowLayout

- (instancetype)initWithColumns:(NSInteger)col andRows:(NSInteger)rows;

@end
