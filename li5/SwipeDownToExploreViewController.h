//
//  SwipeDownToExploreViewController.h
//  li5
//
//  Created by Martin Cocaro on 6/8/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExploreDynamicInteractor.h"

@interface SwipeDownToExploreViewController : UIViewController

@property (weak, nonatomic) id<ExploreViewControllerPanTargetDelegate> searchInteractor;

@end
