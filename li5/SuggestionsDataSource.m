//
//  SuggestionsDataSource.m
//  li5
//
//  Created by Martin Cocaro on 5/24/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import Li5Api;

#import "SuggestionsDataSource.h"
#import "SuggestionsCollectionViewCell.h"

@interface SuggestionsDataSource ()

@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSArray<NSString *> *tags;

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

- (NSString *)getSuggestion:(NSInteger)pos
{
    if (pos >= 0 && pos < _tags.count)
    {
        return _tags[pos];
    }
    return nil;
}

- (void)getSuggestions:(NSString *)word withCompletion:(void (^)(NSError *, NSArray<NSString *> *))completion
{
    Li5ApiHandler *handler = [Li5ApiHandler sharedInstance];
    if (word && word.length > 0)
    {
        self.searchText = word;
        [handler autocompleteFor:word orFetchTags:NO withCompletion:^(NSError *error, NSArray<NSString *> *tags) {
            if (error)
            {
                DDLogError(@"%@", error);
                [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
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
    NSString *tag = [_tags objectAtIndex:indexPath.row];

    NSMutableAttributedString *attTag = [[NSMutableAttributedString alloc] initWithString:tag
                                                                               attributes:@{
                                                                                   NSFontAttributeName : [UIFont fontWithName:@"Rubik-Medium" size:24.0],
                                                                                   NSForegroundColorAttributeName : [UIColor lightGrayColor]
                                                                               }];
    [attTag addAttribute:NSForegroundColorAttributeName value:[UIColor li5_charcoalColor] range:[tag rangeOfString:self.searchText]];

    cell.suggestionLbl.attributedText = attTag;
    
    return cell;
}

@end
