//
//  SuggestionsViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/24/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "SuggestionsViewController.h"
#import "SuggestionsDataSource.h"

@interface SuggestionsViewController ()

@property (nonatomic, strong) SuggestionsDataSource *dataSource;

@end

@implementation SuggestionsViewController

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _dataSource = [SuggestionsDataSource new];
    }
    return self;
}

#pragma mark - UI Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_suggestionsCollectionView setDataSource:_dataSource];
    //Loading Categories
    [self fetchTagsFor:nil];
}

#pragma mark - User Actions

- (void)searchBar:(Li5SearchBarUIView *)searchBar textDidChange:(NSString *)searchText
{
    [self fetchTagsFor:searchText];
}

#pragma mark - View Models

- (void)fetchTagsFor:(NSString*)word
{
    [_dataSource getSuggestions:word withCompletion:^(NSError *error, NSArray<NSString *> *tags) {
        if (!error)
        {
            [_suggestionsCollectionView reloadData];
        }
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tag = [_dataSource getSuggestion:indexPath.row];
    if (self.delegate)
    {
        [self.delegate updateSearchBardWith:tag];
    }
}

#pragma mark - OS ACtions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
