//
//  UIView+Li5.m
//  li5
//
//  Created by Martin Cocaro on 6/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "UIView+Li5.h"

@implementation UIView (Li5)

-(NSLayoutConstraint *)constraintForIdentifier:(NSString *)identifier {
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([constraint.identifier isEqualToString:identifier]) {
            return constraint;
        }
    }
    return nil;
}

@end
