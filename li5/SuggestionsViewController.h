//
//  SuggestionsViewController.h
//  li5
//
//  Created by Martin Cocaro on 5/24/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "ExploreViewController.h"

@interface SuggestionsViewController : UIViewController <Li5SearchBarUIViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *suggestionsCollectionView;

@property (weak, nonatomic) UIViewController<ExploreViewControllerDelegate> *delegate;

@end
