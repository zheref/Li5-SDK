//
//  CategoriesViewController.h
//  li5
//
//  Created by Leandro Fournier on 4/15/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import Li5Api;

@interface CategoriesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) Profile *userProfile;

@end
