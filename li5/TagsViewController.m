//
//  TagsViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "TagsViewController.h"
#import "TagsViewDataSource.h"

@interface TagsViewController ()

@property (nonatomic, strong) TagsViewDataSource *tagsDataSource;

@end

@implementation TagsViewController

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _tagsDataSource = [TagsViewDataSource new];
    }
    return self;
}

#pragma mark - UI Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_tagsCollectionView setDataSource:_tagsDataSource];
    //Loading Categories
    [self fetchTagsFor:nil];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Tag *tag = [_tagsDataSource getTag:indexPath.row];
    if (self.delegate)
    {
        [self.delegate appendSearchBardWith:tag.name];
    }
}

#pragma mark - User Actions

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self fetchTagsFor:searchText];
}

#pragma mark - View Models

- (void)fetchTagsFor:(NSString*)word
{
    [_tagsDataSource getTags:word withCompletion:^(NSError *error, NSArray<Tag *> *tags) {
        if (!error)
        {
            [_tagsCollectionView reloadData];
        }
    }];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end