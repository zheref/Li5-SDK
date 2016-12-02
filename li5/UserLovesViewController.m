//
//  UserLovesViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/21/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "UserLovesViewController.h"
#import "UserProductsCollectionViewDataSource.h"
#import "PrimeTimeViewController.h"

@interface UserLovesViewController ()

@property (nonatomic, strong) UserProductsCollectionViewDataSource *source;
@property (weak, nonatomic) IBOutlet UILabel *noLovesView;

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
    [super viewDidLoad];
    [_noLovesView setHidden:YES];
    [_productsListView setHidden:NO];
    
    NSString *message = @"You haven't [heart] loved any products yet!";
    NSString *redWords = @"loved";
    NSString *heartImage = @"[heart]";
    NSTextAttachment *loveImageAttachment = [NSTextAttachment new];
    loveImageAttachment.image = [UIImage imageNamed:@"heart_red_border"];
    NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:loveImageAttachment];
    
    NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:message
                                                                      attributes:@{
                                                                          NSFontAttributeName : [UIFont fontWithName:@"Rubik-Bold" size:32.0],
                                                                          NSForegroundColorAttributeName : [UIColor li5_charcoalColor]
                                                                      }];
    [attrMessage addAttribute:NSForegroundColorAttributeName value:[UIColor li5_redColor] range:[message rangeOfString:redWords]];
    
    [attrMessage replaceCharactersInRange:[message rangeOfString:heartImage] withAttributedString:imageAttr];
    
    [_noLovesView setAttributedText:attrMessage];
    
    [_productsListView setDelegate:self];
    [_productsListView.collectionView setDataSource:_source];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        [_source startFetchingProductsInBackgroundWithCompletion:^(NSError *error) {
            [_noLovesView setHidden:([_source numberOfProducts] != 0)];
            [_productsListView setHidden:([_source numberOfProducts] == 0)];
            [_productsListView.collectionView reloadData];
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
            }
            
            [_productsListView.collectionView reloadData];
            completion();
        }];
    }];
}

@end
