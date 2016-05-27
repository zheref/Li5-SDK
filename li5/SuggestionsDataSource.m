//
//  SuggestionsDataSource.m
//  li5
//
//  Created by Martin Cocaro on 5/24/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "SuggestionsDataSource.h"
#import "SuggestionsCollectionViewCell.h"

@interface SuggestionsDataSource ()

@property (nonatomic, strong) NSArray<Tag *> *tags;

@end

@implementation SuggestionsDataSource

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

- (Tag *)getSuggestion:(NSInteger)pos
{
    if (pos >= 0 && pos < _tags.count)
    {
        return (Tag *)_tags[pos];
    }
    return nil;
}

- (void)getSuggestions:(NSString *)word withCompletion:(void (^)(NSError *, NSArray<JSONModel *> *))completion
{
    Li5ApiHandler *handler = [Li5ApiHandler sharedInstance];
    if (word && word.length > 0)
    {
        [handler autocompleteFor:word withCompletion:^(NSError *error, NSArray<Tag *> *tags) {
            if (error)
            {
                DDLogError(@"%@", error);
                completion(error,nil);
            }
            else
            {
                DDLogVerbose(@"total suggestions: %lu", (unsigned long)tags.count);
                _tags = [NSArray arrayWithArray:tags];
                completion(error, _tags);
            }
        }];
    }
    
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
    SuggestionsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"suggestionView" forIndexPath:indexPath];
    Tag *tag = [_tags objectAtIndex:indexPath.row];
    cell.suggestionLbl.text = tag.name;
    
    return cell;
}

@end
