//
//  CategoriesViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/15/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import AVFoundation;
@import Li5Api;

#import "CategoriesViewController.h"
#import "CategoriesCollectionViewCell.h"
#import "Li5Constants.h"
#import "AppDelegate.h"

@interface CategoriesViewController () {
    NSOperationQueue *__queue;
}

@property (nonatomic, strong) NSArray<Category *> *allCategories;
@property (nonatomic, strong) NSMutableArray *selectedCategoriesIDs;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;

- (IBAction)continueBtnPressed:(id)sender;

@end

@implementation CategoriesViewController

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    __queue = [[NSOperationQueue alloc] init];
    [__queue setName:@"Categories Queue"];
    _allCategories = [NSArray array];
    _selectedCategoriesIDs = [NSMutableArray array];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(updateUserProfile)
                               name:kProfileUpdated
                             object:nil];
}

#pragma mark - UI Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_collectionView setAllowsMultipleSelection:YES];
    
    [_continueBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] andRect:_continueBtn.bounds] forState:UIControlStateDisabled];
    [_continueBtn setBackgroundImage:[UIImage imageWithColor:[UIColor li5_redColor] andRect:_continueBtn.bounds] forState:UIControlStateNormal];
    
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    __weak typeof(self) welf = self;
    [__queue addOperationWithBlock:^{
        [li5 requestCategoriesWithCompletion:^(NSError *error, NSArray<Category *> *categories) {
            if (error == nil) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    _allCategories = [NSArray arrayWithArray:categories];
                    [welf populateSavedUserCategories];
                }];
            }
        }];
    }];
}

- (void)updateUserProfile
{
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    self.userProfile = flowController.userProfile;
    [self populateSavedUserCategories];
}

- (void)populateSavedUserCategories
{
    [self.selectedCategoriesIDs removeAllObjects];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"Li5DiscoverModeCustom"])
    {
        if ([self.userProfile.preferences count] > 0) {
            for (Category *category in self.userProfile.preferences) {
                [self.selectedCategoriesIDs addObject:category.id];
            }
        }
    }
    [self.collectionView reloadData];
    [self checkSelectedCategories];
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

- (IBAction)continueBtnPressed:(id)sender
{
    Li5ApiHandler *li5 = [Li5ApiHandler sharedInstance];
    [li5 changeUserProfileWithCategoriesIDs:[NSArray arrayWithArray:_selectedCategoriesIDs] withCompletion:^(NSError *error) {
        if (error == nil) {
            
            BOOL showCategoriesSelection = [_selectedCategoriesIDs count] < 2;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:!showCategoriesSelection forKey:kLi5CategoriesSelectionViewPresented];
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:kCategoriesUpdateSuccessful object:nil];
        } else {
            DDLogError(@"Couldn't commit selected categories: %@", error.description);
            [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:kCategoriesUpdateFailed object:nil];
        }
    }];
}

#pragma mark - Helpers

- (void)checkSelectedCategories {
    switch([_selectedCategoriesIDs count])
    {
        case 0:
            [self.continueBtn setTitle:NSLocalizedString(@"SELECT AT LEAST 2!",nil) forState:UIControlStateDisabled];
            break;
        case 1:
            [self.continueBtn setTitle:NSLocalizedString(@"SELECT 1 MORE!",nil) forState:UIControlStateDisabled];
            break;
    }
    [self.continueBtn setEnabled:([_selectedCategoriesIDs count] >= 2)];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
