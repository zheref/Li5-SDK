//
//  UserOrdersViewController.m
//  li5
//
//  Created by Martin Cocaro on 6/6/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "UserOrdersViewController.h"
#import "ProductsListView.h"
#import "UserOrdersCollectionViewDataSource.h"
#import "PrimeTimeViewController.h"

@interface UserOrdersViewController ()

@property (nonatomic, strong) UserOrdersCollectionViewDataSource *source;
@property (weak, nonatomic) IBOutlet ProductsListView *ordersListView;
@property (weak, nonatomic) IBOutlet UILabel *noOrdersView;

@end

@implementation UserOrdersViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _source = [UserOrdersCollectionViewDataSource new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_noOrdersView setHidden:YES];
    [_ordersListView setHidden:NO];
    
    NSString *message = NSLocalizedString(@"You haven't made any orders yet!",nil);
    NSString *redWords = @"orders";
    NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:message
                                                                                    attributes:@{
                                                                                                 NSFontAttributeName : [UIFont fontWithName:@"Rubik-Bold" size:32.0],
                                                                                                 NSForegroundColorAttributeName : [UIColor li5_charcoalColor]
                                                                                                 }];
    [attrMessage addAttribute:NSForegroundColorAttributeName value:[UIColor li5_redColor] range:[message rangeOfString:redWords]];
    [_noOrdersView setAttributedText:attrMessage];
    
    [_ordersListView setDelegate:self];
    [_ordersListView.collectionView setDataSource:_source];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        [_source startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
            [_noOrdersView setHidden:([_source numberOfProducts] != 0)];
            [_ordersListView setHidden:([_source numberOfProducts] == 0)];
            [_ordersListView.collectionView reloadData];
        }];
    }];
}

#pragma mark - User Actions

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PrimeTimeViewController *vc = [[PrimeTimeViewController alloc] initWithDataSource:_source];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.modalPresentationCapturesStatusBarAppearance = YES;
    [vc setStartIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)fetchMoreProductsWithCompletion:(void (^)(void))completion
{
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        [_source fetchMoreProductsWithCompletion:^(NSError *error) {
            if (error != nil)
            {
                DDLogError(@"Error fetching more products: %@", error);
                [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
            }
            
            [_ordersListView.collectionView reloadData];
            completion();
        }];
    }];
}

@end
