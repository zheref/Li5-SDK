//
//  Li5SearchBarUICollectionViewCell.m
//  li5
//
//  Created by Martin Cocaro on 6/9/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5SearchBarUICollectionViewCell.h"

@implementation Li5SearchBarUICollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = NO;
}

@end
