//
//  SuggestionsDataSource.h
//  li5
//
//  Created by Martin Cocaro on 5/24/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@interface SuggestionsDataSource : NSObject<UICollectionViewDataSource>

- (Tag*)getSuggestion:(NSInteger)pos;

- (void)getSuggestions:(NSString*)word withCompletion:(void (^)(NSError *error,NSArray<JSONModel*>* tags))completion;

@end
