//
//  UserLovesViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/21/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "UserLovesViewController.h"
#import "UserProductsCollectionViewDataSource.h"
#import "PrimeTimeViewController.h"

@interface UserLovesViewController ()

@property (nonatomic, strong) UserProductsCollectionViewDataSource *source;

@end

@implementation UserLovesViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _source = [UserProductsCollectionViewDataSource new];
    }
    return self;
}

- (void)viewDidLoad
{
    [_productsListView setDelegate:self];
    [_productsListView.collectionView setDataSource:_source];
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        [_source getUserLovesWithCompletion:^(NSError *error) {
            [_productsListView.collectionView reloadData];
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - User Actions

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PrimeTimeViewController *vc = [[PrimeTimeViewController alloc] initWithDataSource:_source];
    [vc setStartIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)fetchMoreProductsWithCompletion:(void (^)(void))completion
{
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        [_source fetchMoreUserLovesWithCompletion:^(NSError *error) {
            if (error != nil)
            {
                DDLogError(@"Error fetching more products: %@", error);
            }
            
            [_productsListView.collectionView reloadData];
            completion();
        }];
    }];
}

@end
