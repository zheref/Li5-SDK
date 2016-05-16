//
//  ProductsViewController.h
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@protocol ProductsViewControllerPanTargetDelegate <NSObject>

- (void)userDidPan:(UIPanGestureRecognizer *)gestureRecognizer;

- (void)presentViewWithCompletion:(void (^)(void))completion;

- (void)dismissViewWithCompletion:(void (^)(void))completion;

@end

@interface ProductsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, readonly) id<ProductsViewControllerPanTargetDelegate> panTarget;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil panTarget:(id<ProductsViewControllerPanTargetDelegate>)panTarget;

@end