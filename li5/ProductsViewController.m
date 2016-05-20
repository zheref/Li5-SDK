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
#import "TagsViewDataSource.h"
#import "HorizontalUICollectionViewFlowLayout.h"

@interface ProductsViewController () <UISearchBarDelegate>
{
    BOOL isFetching;
    
    UIPanGestureRecognizer *goBackPanGestureRecognizer;
}

@property (nonatomic, strong) ProductsCollectionViewDataSource *source;
@property (nonatomic, strong) NSString *queryString;

@property (nonatomic, strong) TagsViewDataSource *tagsDataSource;
@property (nonatomic, strong) UICollectionView *tagsCollectionView;

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

    //Data Sources
    _tagsDataSource = [TagsViewDataSource new];
    _source = [ProductsCollectionViewDataSource new];
    isFetching = NO;
    
    //Products Collection View
    UICollectionViewFlowLayout *layout = [[HorizontalUICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumLineSpacing:0.0f];
    [layout setMinimumInteritemSpacing:0.0f];
    [layout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_collectionView setCollectionViewLayout:layout animated:NO completion:nil];
    [_collectionView registerNib:[UINib nibWithNibName:@"ProductsCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setAllowsMultipleSelection:NO];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setDataSource:_source];
    [_collectionView setDelegate:self];
    [_collectionView setPagingEnabled:TRUE];
    
    //Tags Collection View
    UICollectionViewFlowLayout *tagsLayout = [[UICollectionViewFlowLayout alloc] init];
    [tagsLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [tagsLayout setMinimumLineSpacing:0.0f];
    [tagsLayout setMinimumInteritemSpacing:0.0f];
    [tagsLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    _tagsCollectionView = [[UICollectionView alloc] initWithFrame:_collectionView.frame collectionViewLayout:tagsLayout];
    [_tagsCollectionView setPagingEnabled:NO];
    [_tagsCollectionView setCollectionViewLayout:tagsLayout animated:NO completion:nil];
    [_tagsCollectionView registerNib:[UINib nibWithNibName:@"TagsCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"tagsViewCell"];
    [_tagsCollectionView setAllowsMultipleSelection:NO];
    [_tagsCollectionView setDataSource:_tagsDataSource];
    [_tagsCollectionView setBackgroundColor:[UIColor whiteColor]];
    [_tagsCollectionView setContentSize:_collectionView.frame.size];
    [_tagsCollectionView setDelegate:self];

    [self.view insertSubview:_tagsCollectionView belowSubview:_collectionView];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setupGestureRecognizers];
    
    [self fetchProducts];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _collectionView)
    {
        CGFloat width = collectionView.frame.size.width / 3;
        CGFloat height = collectionView.frame.size.height / 3;
        CGSize size = CGSizeMake(width, height);
        return size;
    }

    return CGSizeMake(collectionView.frame.size.width,30);
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
    if (collectionView == _collectionView)
    {
        PrimeTimeViewController *vc = [[PrimeTimeViewController alloc] initWithDataSource:_source];
        [vc setStartIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:NO];
    }
    else
    {
        Tag *tag = [_tagsDataSource getTag:indexPath.row];
        [_searchBar setText:[[_searchBar text] stringByAppendingFormat:@" %@",tag.name]];
        [self searchBarSearchButtonClicked: _searchBar];
    }
}

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self fetchTagsFor:searchText];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:YES animated:TRUE];
    [_tagsCollectionView setFrame:_collectionView.frame];
    [self.view bringSubviewToFront:_tagsCollectionView];
    [self fetchTagsFor:@""];
    return TRUE;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchText = searchBar.text;
    if (searchText.length > 0)
    {
        [_source isSearching];
        [self.view endEditing:YES];
        [_searchBar setShowsCancelButton:NO animated:TRUE];
        [self.view bringSubviewToFront:_collectionView];
        self.queryString = searchText;
        [self fetchProducts];
    }
    else
    {
        [self searchBarCancelButtonClicked:_searchBar];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:TRUE];
    [self.view endEditing:true];
    [self.view bringSubviewToFront:_collectionView];
    [_searchBar setText:@""];
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
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    
    NSInteger totalPages = (int) scrollView.contentSize.width / scrollView.frame.size.width;
    
    if (page >= totalPages -1 )
    {
        [self fetchProducts];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:true];
}

#pragma mark - Helpers

- (void)fetchTagsFor:(NSString*)word
{
    [_tagsDataSource getTags:word withCompletion:^(NSError *error, NSArray<Tag *> *tags) {
        if (!error)
        {
            [_tagsCollectionView reloadData];
        }
    }];
}

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

#pragma mark - Gesture Recognizers

- (void)userDidPan:(UIPanGestureRecognizer *)recognizer
{
    [_panTarget userDidPan:recognizer];
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
        return (touch.y >= 50) && (fabs(degree) > 20.0);
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

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
