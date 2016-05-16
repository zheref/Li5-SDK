//
//  CategoriesViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/15/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "CategoriesViewController.h"
#import "CategoriesCollectionViewCell.h"
#import "PrimeTimeViewController.h"
#import "PrimeTimeViewControllerDataSource.h"

@interface CategoriesViewController ()

@property (nonatomic, strong) NSArray<Category *> *allCategories;
@property (nonatomic, strong) NSMutableArray *selectedCategoriesIDs;

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _allCategories = [NSArray array];
    _selectedCategoriesIDs = [NSMutableArray array];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [_collectionView setCollectionViewLayout:layout animated:true completion:nil];
    [_collectionView registerNib:[UINib nibWithNibName:@"CategoriesCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setAllowsMultipleSelection:true];
    
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    __weak typeof(self) welf = self;
    [li5 requestCategoriesWithCompletion:^(NSError *error, NSArray<Category *> *categories) {
        if (error == nil) {
            _allCategories = [NSArray arrayWithArray:categories];
            [li5 requestProfile:^(NSError *error, Profile *profile) {
                if (error == nil) {
                    if ([profile.preferences.data count] > 0) {
                        for (Category *category in profile.preferences.data) {
                            [welf.selectedCategoriesIDs addObject:category.id];
                        }
                    }
                }
                [welf.collectionView reloadData];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_allCategories count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoriesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.titleLbl.text = [[_allCategories objectAtIndex:indexPath.row] name];
    if ([_selectedCategoriesIDs containsObject:[[_allCategories objectAtIndex:indexPath.row] id]]) {
        [collectionView selectItemAtIndexPath:indexPath animated:true scrollPosition:UICollectionViewScrollPositionNone];
        [cell setBackgroundColor:[UIColor blueColor]];
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:true];
        [cell setBackgroundColor:[UIColor blackColor]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat side = collectionView.frame.size.width / 3 - collectionView.layoutMargins.left;
    return CGSizeMake(side, side);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoriesCollectionViewCell *cell = (CategoriesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor blueColor]];
    [_selectedCategoriesIDs addObject:[[_allCategories objectAtIndex:indexPath.row] id]];
    [self checkSelectedCategories];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoriesCollectionViewCell *cell = (CategoriesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor blackColor]];
    [_selectedCategoriesIDs removeObject:[[_allCategories objectAtIndex:indexPath.row] id]];
    [self checkSelectedCategories];
}

#pragma mark - Actions

- (IBAction)continueBtnPressed:(id)sender {
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 changeUserProfileWithCategoriesIDs:[NSArray arrayWithArray:_selectedCategoriesIDs] withCompletion:^(NSError *error) {
        if (error == nil) {
            PrimeTimeViewControllerDataSource *primeTimeSource = [PrimeTimeViewControllerDataSource new];
            PrimeTimeViewController *primeTimeVC = [[PrimeTimeViewController alloc] initWithDataSource:primeTimeSource];
            [primeTimeSource startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
                if (error != nil)
                {
                    DDLogVerbose(@"ERROR %@", error.description);
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.navigationController pushViewController:primeTimeVC animated:NO];
                });
            }];
        } else {
            DDLogVerbose(@"Couldn't commit selected categories.");
        }
    }];
}

#pragma mark - Helpers

- (void)checkSelectedCategories {
    if ([_selectedCategoriesIDs count] >= 2) {
        [self.continueBtn setEnabled:true];
    } else {
        [self.continueBtn setEnabled:false];
    }
}

@end
