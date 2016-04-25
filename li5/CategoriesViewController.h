//
//  CategoriesViewController.h
//  li5
//
//  Created by Leandro Fournier on 4/15/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@interface CategoriesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;

- (IBAction)continueBtnPressed:(id)sender;

@end
