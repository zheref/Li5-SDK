//
//  TagsViewController.h
//  li5
//
//  Created by Martin Cocaro on 5/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ExploreViewController.h"

@interface TagsViewController : UIViewController <Li5SearchBarUIViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *tagsCollectionView;

@property (weak, nonatomic) UIViewController<ExploreViewControllerDelegate> *delegate;

@end
