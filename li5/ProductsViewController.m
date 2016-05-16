//
//  ProductsViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "PrimeTimeViewController.h"
#import "PrimeTimeViewController.h"
#import "ProductsCollectionViewCell.h"
#import "ProductsCollectionViewDataSource.h"
#import "ProductsViewController.h"

@interface ProductsViewController () <UISearchBarDelegate>
{
    BOOL isFetching;
    
    UIPanGestureRecognizer *goBackPanGestureRecognizer;
}

@property (nonatomic, strong) ProductsCollectionViewDataSource *source;
@property (nonatomic, strong) NSString *queryString;

@end

@implementation ProductsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil panTarget:(id<ProductsViewControllerPanTargetDelegate>)panTarget
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _panTarget = panTarget;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _source = [ProductsCollectionViewDataSource new];
    _collectionView.dataSource = _source;
    isFetching = NO;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumLineSpacing:0.0f];
    [layout setMinimumInteritemSpacing:0.0f];
    [_collectionView setCollectionViewLayout:layout animated:true completion:nil];
    [_collectionView registerNib:[UINib nibWithNibName:@"ProductsCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setAllowsMultipleSelection:true];
    
    [self setupGestureRecognizers];
    
    [self fetchProducts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = collectionView.frame.size.width / 3;
    CGFloat height = collectionView.frame.size.height / 3;
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PrimeTimeViewController *vc = [[PrimeTimeViewController alloc] initWithDataSource:_source];
    [vc setStartIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - Gesture Recognizers

- (void)userDidPan:(UIPanGestureRecognizer *)recognizer
{
    if ( recognizer.state == UIGestureRecognizerStateBegan )
    {
        [_panTarget userDidPan:nil];
    }
}

- (void)setupGestureRecognizers
{
    goBackPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    goBackPanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:goBackPanGestureRecognizer];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touch = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (gestureRecognizer == goBackPanGestureRecognizer)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
        return (touch.y >= 50) && (fabs(degree) > 20.0) && (velocity.y < 0);
    }
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([[gestureRecognizer view] isKindOfClass:[UIScrollView class]])
    {
        if (otherGestureRecognizer == goBackPanGestureRecognizer)
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 2)
    {
        [_source isSearching];
        self.queryString = searchText;
        [self fetchProducts];
    }
    else
    {
        [self cancelSearch];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:true];
    [self cancelSearch];
}

- (void)cancelSearch
{
    if (self.queryString)
    {
        [_source isNotSearching];
        self.queryString = nil;
        [self.collectionView reloadData];
    }
}

#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= scrollView.contentSize.height / 2)
    {
        [self fetchProducts];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:true];
}

#pragma mark - Helpers

- (void)fetchProducts
{
    if (!isFetching)
    {
        isFetching = YES;
        [_source getProductsWithQuery:_queryString withCompletion:^(NSError *error) {
          isFetching = NO;
          if (error == nil)
          {
              [_collectionView reloadData];
          }
          else
          {
              DDLogError(@"Error fetching products: %@", error);
          }
        }];
    }
}

@end
