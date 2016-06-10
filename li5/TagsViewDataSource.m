//
//  TagsViewDataSource.m
//  li5
//
//  Created by Martin Cocaro on 5/16/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "TagsCollectionViewCell.h"
#import "TagsViewDataSource.h"

@interface TagsViewDataSource ()

@property (nonatomic, strong) NSArray<NSString *> *tags;

@end

@implementation TagsViewDataSource

#pragma mark - Public Methods

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _tags = [NSArray array];
    }
    return self;
}

- (NSString *)getTag:(NSInteger)pos
{
    if (pos >= 0 && pos < _tags.count)
    {
        return _tags[pos];
    }
    return nil;
}

- (void)getTags:(NSString *)word withCompletion:(void (^)(NSError *, NSArray<NSString *> *))completion
{
    Li5ApiHandler *handler = [Li5ApiHandler sharedInstance];
    [handler autocompleteFor:word orFetchTags:YES withCompletion:^(NSError *error, NSArray<NSString *> *tags) {
        if (error)
        {
            DDLogError(@"%@", error);
            completion(error,nil);
        }
        else
        {
            DDLogVerbose(@"total tags: %lu", (unsigned long)tags.count);
            _tags = [NSArray arrayWithArray:tags];
            completion(error, _tags);
        }
    }];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_tags count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TagsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tagView" forIndexPath:indexPath];
    NSString *tag = [_tags objectAtIndex:indexPath.row];
    cell.tagNameLbl.text = tag;

    return cell;
}

@end
