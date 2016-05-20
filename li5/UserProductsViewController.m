//
//  UserProductsViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "UserProductsViewController.h"
#import "UserProductsCollectionViewDataSource.h"
#import "PrimeTimeViewController.h"

@interface UserProductsViewController ()

@property (nonatomic, strong) UserProductsCollectionViewDataSource *source;

@end

@implementation UserProductsViewController

- (instancetype)init
{
    DDLogVerbose(@"");
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _source = [UserProductsCollectionViewDataSource new];
    
    [_lovesCollectionView registerNib:[UINib nibWithNibName:@"ProductsCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"lovesCollectionCell"];
    _lovesCollectionView.dataSource = _source;
    _lovesCollectionView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadData];
}

#pragma mark - Data Methods

- (void)reloadData
{
    DDLogVerbose(@"");
    [_source getUserLovesWithCompletion:^(NSError *error) {
        if (!error)
        {
            [_lovesCollectionView reloadData];
        }
    }];
}

#pragma mark - CollectionView Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = collectionView.frame.size.width / 3;
    CGFloat height = collectionView.frame.size.height / 2;
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,0,0,0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PrimeTimeViewController *vc = [[PrimeTimeViewController alloc] initWithDataSource:_source];
    [vc setStartIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
