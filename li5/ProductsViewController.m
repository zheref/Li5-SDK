//
//  ProductsViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/26/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import Li5Api;
@import MMMaterialDesignSpinner;

#import "PrimeTimeViewController.h"
#import "ProductsCollectionViewDataSource.h"
#import "ProductsViewController.h"
#import "ProductsCollectionViewCell.h"

@interface ProductsViewController () <UISearchBarDelegate> {
    NSOperationQueue *__queue;
}

@property (nonatomic, strong) ProductsCollectionViewDataSource *source;
@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *noResultsView;

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

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
    
    _presenting = NO;
}

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    
    _noResultsView.font = [UIFont fontWithName:@"Rubik-Bold" size:32.0];
    _noResultsView.hidden = YES;
    
    _spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0,0,45,45)];
    _spinnerView.lineWidth = 2.0f;
    _spinnerView.tintColor = [UIColor lightGrayColor];
    _spinnerView.hidesWhenStopped = YES;
    [self.view addSubview:_spinnerView];
    
    //Data Sources
    _source = [ProductsCollectionViewDataSource new];
    [_productListView setDelegate:self];
    [_productListView.collectionView setDataSource:_source];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    //    [self exploreProducts:nil];
    
    self.presenting = NO;
}

- (void)viewDidLayoutSubviews
{
    DDLogVerbose(@"");
    [super viewDidLayoutSubviews];
    
    _spinnerView.center = self.view.center;
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
    DDLogVerbose(@"");
    //    [_productListView.collectionView reloadData];
    self.noResultsView.hidden = YES;
    [_spinnerView startAnimating];
    [__queue addOperationWithBlock:^{
        [_source getProductsWithQuery:(searchText.length > 0 ? searchText: nil) progress:^(){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [_productListView.collectionView reloadData];
            }];
        } withCompletion:^(NSError *error) {
            if (error != nil)
            {
                DDLogError(@"Error searching products: %@", error);
                [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [_spinnerView stopAnimating];
                [_productListView.collectionView reloadData];
                self.noResultsView.hidden = [self.source totalProducts] != 0;
            }];
        }];
    }];
}

#pragma mark - User Actions

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"");
    
    if (!self.presenting) {
        self.presenting = YES;
        ProductsCollectionViewCell *cell = (ProductsCollectionViewCell*)[_productListView.collectionView cellForItemAtIndexPath:indexPath];
        
        PrimeTimeViewController *vc = [[PrimeTimeViewController alloc] initWithDataSource:_source];
        [vc setStartIndex:indexPath.row];
        
        CGRect collectionViewBounds = _productListView.collectionView.bounds;
        CGRect windowsBounds =  [UIScreen mainScreen].bounds;
        
        
        CGFloat deltaBetweenViewsY = windowsBounds.size.height - _productListView.frame.size.height;
        
        CGRect frame = CGRectMake(cell.frame.origin.x - collectionViewBounds.origin.x,
                                  cell.frame.origin.y + deltaBetweenViewsY,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
        
        PrimeTimeNavigationViewController *navVc = [[PrimeTimeNavigationViewController alloc] initWithRootViewController:vc];
        navVc.navigationBarHidden = YES;
        
        vc.interactor = [[ExploreProductInteractor alloc] initWithParentViewController:self
                                                               andChildController:navVc
                                                                  andInitialFrame:frame
                                                                          andCell:cell];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:cell.imageView.image];
        
        CGRect rect= CGRectMake(windowsBounds.size.width - (windowsBounds.size.width - frame.origin.x),
                                windowsBounds.size.height - (_productListView.frame.size.height - cell.frame.origin.y),
                                cell.frame.size.width,
                                cell.frame.size.height);
        
        
        [self.parentViewController.view addSubview:image];
        image.frame = rect;
        
        [UIView animateWithDuration:0.4 animations:^{
            
            image.frame = [UIScreen mainScreen].bounds;
            
        } completion:^(BOOL finished) {
            
            [vc.interactor presentViewWithCompletion:^{
                
                [UIView animateWithDuration:0.4 animations:^{
                    
                    image.alpha = 0;
                    cell.hidden = true;
                    
                } completion:^(BOOL finished) {
                    
                    self.presenting = NO;
                }];
            }];
        }];
    }
}


-(void)userDidPan:(UIScreenEdgePanGestureRecognizer *)recognizer {

DDLogVerbose(@"");
}

- (void)fetchMoreProductsWithCompletion:(void (^)(void))completion
{
    DDLogVerbose(@"");
    [__queue addOperationWithBlock:^{
        [_source fetchMoreProductsWithCompletion:^(NSError *error) {
            if (error != nil)
            {
                DDLogError(@"Error fetching more products: %@", error);
                [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
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
