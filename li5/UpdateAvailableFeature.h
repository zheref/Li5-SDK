//
//  UpdateAvailableFeature.h
//  li5
//
//  Created by Martin Cocaro on 2/1/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

@import JSONModel;

#import <Foundation/Foundation.h>

@interface UpdateAvailableFeature : NSObject

- (id)initWithRootViewController:(UIViewController*)rootViewController;

@end

@interface ItunesAppStoreResult : JSONModel

@property (nonatomic, strong) NSString<Optional> *version;

@end

@protocol ItunesAppStoreResult @end

@interface ItunesAppStoreLookup : JSONModel

@property (nonatomic, strong) NSArray<ItunesAppStoreResult>* result;

@end

@protocol ItunesAppStoreLookup @end
