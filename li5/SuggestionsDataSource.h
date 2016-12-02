//
//  SuggestionsDataSource.h
//  li5
//
//  Created by Martin Cocaro on 5/24/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@interface SuggestionsDataSource : NSObject<UICollectionViewDataSource>

- (NSString*)getSuggestion:(NSInteger)pos;

- (void)getSuggestions:(NSString*)word withCompletion:(void (^)(NSError *error,NSArray<NSString*>* tags))completion;

@end
