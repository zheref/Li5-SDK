//
//  PrimeTimeViewController.h
//  li5
//
//  Created by Martin Cocaro on 4/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "PrimeTimeViewControllerDataSource.h"
#import "Li5UIPageViewController.h"

@interface PrimeTimeViewController : Li5UIPageViewController

- (instancetype)initWithDataSource:(PrimeTimeViewControllerDataSource*)source;

- (void)setStartIndex:(NSInteger)idx;

@end
