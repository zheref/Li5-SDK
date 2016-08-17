//
//  ProductsViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "PrimeTimeViewController.h"
#import "ProductsCollectionViewDataSource.h"
#import "ProductsViewController.h"

@interface ProductsViewController () <UISearchBarDelegate> {
    NSOperationQueue *__queue;
}

@property (nonatomic, strong) ProductsCollectionViewDataSource *source;

@end

@implementation ProductsViewController

#pragma mark - UI Setup

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
    [__queue setName:@"Explore Queue"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Data Sources
    _source = [ProductsCollectionViewDataSource new];
    [_productListView setDelegate:self];
    [_productListView.collectionView setDataSource:_source];
    
    [self exploreProducts:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    [self exploreProducts:nil];
}

#pragma mark - User Actions

- (void)searchButtonClicked:(Li5SearchBarUIView *)searchBar
{
    [self exploreProducts:searchBar.text];
}

- (void)cancelButtonClicked:(Li5SearchBarUIView *)searchBar
{
    [self exploreProducts:searchBar.text];
}

#pragma mark - View Model

- (void)exploreProducts:(NSString*)searchText
{
    [__queue addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_productListView.collectionView reloadData];
        }];
        [_source getProductsWithQuery:(searchText.length > 0 ? searchText: nil) withCompletion:^(NSError *error) {
            if (error != nil)
            {
                DDLogError(@"Error searching products: %@", error);
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [_productListView.collectionView reloadData];
            }];
        }];
    }];
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
    [__queue addOperationWithBlock:^{
        [_source fetchMoreProductsWithCompletion:^(NSError *error) {
            if (error != nil)
            {
                DDLogError(@"Error fetching more products: %@", error);
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [_productListView.collectionView reloadData];
            }];
            completion();
        }];
    }];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
