//
//  ProductPageViewController.h
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;
@import BCVideoPlayer;

#import "DetailsViewController.h"
#import "VideoViewController.h"
#import "Li5UIPageViewController.h"

@interface ProductPageViewController : Li5UIPageViewController <DisplayableProtocol>

- (id)initWithProduct:(Product *)thisProduct forContext:(ProductContext)context;
- (id)initWithOrder:(Order *)thisProduct forContext:(ProductContext)context;

- (void)setPriority:(BCPriority)priority;

- (BCPlayer *)getPlayer;

@end
