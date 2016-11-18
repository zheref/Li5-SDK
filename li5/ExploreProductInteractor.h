//
//  ExploreProductInteractor.h
//  li5
//
//  Created by gustavo hansen on 11/4/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExploreProductInteractor : UIPercentDrivenInteractiveTransition


-(id)initWithParentViewController:(UIViewController *)viewController andChildController: (UIViewController *) child andInitialFrame: (CGRect)frame andCell:(UICollectionViewCell *)cell;

-(void)userDidPan:(UIPanGestureRecognizer *)recognizer;

- (void)presentViewWithCompletion:(void (^)(void))completion;

@end
