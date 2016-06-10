//
//  TagsViewDataSource.h
//  li5
//
//  Created by Martin Cocaro on 5/16/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagsViewDataSource : NSObject<UICollectionViewDataSource>

- (NSString*)getTag:(NSInteger)pos;

- (void)getTags:(NSString*)word withCompletion:(void (^)(NSError *error,NSArray<NSString*>* tags))completion;

@end
