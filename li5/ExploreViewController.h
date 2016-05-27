//
//  SearchViewController.h
//  li5
//
//  Created by Martin Cocaro on 5/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExploreViewControllerPanTargetDelegate <NSObject>

- (void)userDidPan:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)presentViewWithCompletion:(void (^)(void))completion;
- (void)dismissViewWithCompletion:(void (^)(void))completion;

@end

@protocol ExploreViewControllerDelegate <NSObject>

- (void)updateSearchBardWith:(NSString*)text;
- (void)appendSearchBardWith:(NSString *)text;

@end

@interface ExploreViewController : UIViewController <UISearchBarDelegate, UIGestureRecognizerDelegate, ExploreViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIView *suggestionsView;

@property (weak, nonatomic) IBOutlet UIView *exploreView;

@property (weak, nonatomic) id<ExploreViewControllerPanTargetDelegate> panTarget;

@end
