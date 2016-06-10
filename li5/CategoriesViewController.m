//
//  CategoriesViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/15/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import AVFoundation;
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

#pragma mark - Init

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OnboardingViews" bundle:[NSBundle mainBundle]];
    self = [storyboard instantiateViewControllerWithIdentifier:@"OnboardingCategoriesView"];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _allCategories = [NSArray array];
    _selectedCategoriesIDs = [NSMutableArray array];
}

#pragma mark - UI Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_collectionView setAllowsMultipleSelection:YES];
    
    [_continueBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] andRect:_continueBtn.bounds] forState:UIControlStateDisabled];
    [_continueBtn setBackgroundImage:[UIImage imageWithColor:[UIColor li5_redColor] andRect:_continueBtn.bounds] forState:UIControlStateNormal];
    [_continueBtn setHidden:TRUE];
    
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
                [welf checkSelectedCategories];
            }];
        }
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_allCategories count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoriesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryView" forIndexPath:indexPath];
    cell.layer.cornerRadius = MIN(cell.frame.size.height,cell.frame.size.width) / 2;
    
    [cell setCategory:[_allCategories objectAtIndex:indexPath.row]];
    
    if ([_selectedCategoriesIDs containsObject:[[_allCategories objectAtIndex:indexPath.row] id]]) {
        [self.collectionView selectItemAtIndexPath:indexPath animated:true scrollPosition:UICollectionViewScrollPositionNone];
        cell.selected = TRUE;
    } else {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
        cell.selected = FALSE;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    UIEdgeInsets insets = layout.sectionInset;
    
    CGFloat width = (collectionView.frame.size.width -  insets.left - insets.right - 2*layout.minimumLineSpacing) / 3;
    CGFloat height = (collectionView.frame.size.height - insets.top - insets.bottom - 2*layout.minimumInteritemSpacing ) / 3;
    CGFloat minValue = MIN(width,height);
    return CGSizeMake(minValue, minValue);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoriesCollectionViewCell *cell = (CategoriesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:TRUE];
    [_selectedCategoriesIDs addObject:[[_allCategories objectAtIndex:indexPath.row] id]];
    [self checkSelectedCategories];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoriesCollectionViewCell *cell = (CategoriesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:FALSE];
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
    [self.continueBtn setHidden:([_selectedCategoriesIDs count] == 0)];
    [self.continueBtn setEnabled:([_selectedCategoriesIDs count] >= 2)];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
