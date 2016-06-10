//
//  SearchViewController.h
//  li5
//
//  Created by Martin Cocaro on 5/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5SearchBarUIView.h"

@protocol ExploreViewControllerPanTargetDelegate <NSObject>

- (void)userDidPan:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)presentViewWithCompletion:(void (^)(void))completion;
- (void)dismissViewWithCompletion:(void (^)(void))completion;

@end

@protocol ExploreViewControllerDelegate <NSObject>

- (void)updateSearchBardWith:(NSString*)text;
- (void)appendSearchBardWith:(NSString *)text;

@end

@interface ExploreViewController : UIViewController <Li5SearchBarUIViewDelegate, UIGestureRecognizerDelegate, ExploreViewControllerDelegate>

@property (weak, nonatomic) id<ExploreViewControllerPanTargetDelegate> panTarget;

@end
