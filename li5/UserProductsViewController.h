//
//  UserProductsViewController.h
//  li5
//
//  Created by Martin Cocaro on 5/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProductsViewController : UIViewController <UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (weak, nonatomic) IBOutlet UICollectionView *lovesCollectionView;

- (void)reloadData;

@end
