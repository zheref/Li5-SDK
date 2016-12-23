//
//  PrimeTimeViewController.h
//  li5
//
//  Created by Martin Cocaro on 4/23/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "PrimeTimeViewControllerDataSource.h"
#import "Li5UIPageViewController.h"
#import "ExploreProductInteractor.h"

@interface PrimeTimeViewController : Li5UIPageViewController

- (instancetype)initWithDataSource:(PrimeTimeViewControllerDataSource*)source;

- (void)setStartIndex:(NSInteger)idx;

@property (nonatomic, retain) ExploreProductInteractor *interactor;

@end

@interface PrimeTimeNavigationViewController : UINavigationController

@end
