//
//  li5_api_ios.h
//  li5-api-ios
//
//  Created by Leandro Fournier on 4/12/16.
//  Copyright © 2016 Leandro Fournier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSKeychain.h"
#import "Product.h"
#import "Products.h"
#import "Category.h"
#import "Categories.h"
#import "Profile.h"
#import "Profiles.h"

#define Li5API_SERVICE                                          @"Li5APIService"
#define Li5API_ACCESS_TOKEN_SECONDS_LEFT_TO_BE_REFRESHED        120.0

#define Li5API_USERDEFAULTS_KEY_USER                            @"Li5API_USERDEFAULTS_KEY_USER"
#define Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN                    @"Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN"
#define Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN_EXPIRATION_DATE    @"Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN_EXPIRATION_DATE"

#define Li5API_ENDPOINT_GET_ACCESS_TOKEN                        @"authorize"
#define Li5API_ENDPOINT_DISCOVER_PRODUCTS                       @"discover"
#define Li5API_ENDPOINT_PRODUCTS                                @"products"
#define Li5API_ENDPOINT_REFRESH_TOKEN                           @"delegation"
#define Li5API_ENDPOINT_REVOKE_REFRESH_ACCESS_TOKEN             @"credentials"
#define Li5API_ENDPOINT_GET_CATEGORIES                          @"categories"
#define Li5API_ENDPOINT_PROFILE                                 @"profile"
#define Li5API_ENDPOINT_VIEW                                    @"products/{id}/actions/view"
#define Li5API_ENDPOINT_LOVE                                    @"products/{id}/actions/love"

typedef enum {
    Li5VideoTypeTrailer = 1,
    Li5VideoTypeFull = 2,
} Li5VideoType;

typedef enum {
    Li5ContextDiscover = 1,
    Li5ContextSearch = 2,
    Li5ContextRelated = 3
} Li5Context;

@interface Li5ApiHandler : NSObject

@property (nonatomic, strong) NSString *baseURL;

+ (Li5ApiHandler *)sharedInstance;
- (void)login:(NSString *)user withPassword:(NSString *)password withCompletion:(void (^)(NSError* error))completion;
- (void)login:(NSString *)user withFacebookToken:(NSString *)token withCompletion:(void (^)(NSError *error))completion;
- (BOOL)isAccessTokenAboutToBeingRevoked;
- (void)checkAccessTokenAvailabilityAndPerform:(void (^)(NSError *error))block;
- (void)requestDiscoverProductsWithCompletion:(void (^)(NSError *error, NSArray <Product *> *products))completion;
- (void)refreshAccessTokenWithCompletion:(void (^)(NSError *error))completion;
- (void)revokeRefreshAccessTokenWithCompletion:(void (^)(NSError *error))completion;
- (void)requestCategoriesWithCompletion:(void (^)(NSError *error, NSArray<Category *> *categories))completion;
- (void)requestProfile:(void (^)(NSError *error, Profile *profile))completion;
- (void)changeUserProfileWithCategoriesIDs:(NSArray *)categories withCompletion:(void (^)(NSError *error))completion;
- (void)postUserWatchedVideoWithID:(NSString *)productID withType:(Li5VideoType)type during:(NSNumber *)seconds inContext:(Li5Context)context withCompletion:(void (^)(NSError *error))completion;
- (void)postLoveForProductWithID:(NSString *)productID withCompletion:(void (^)(NSError *error))completion;
- (void)deleteLoveForProductWithID:(NSString *)productID withCompletion:(void (^)(NSError *error))completion;

- (NSString *)user;
- (NSString *)accessToken;
- (NSDate *)accessTokenExpirationDate;
- (NSString *)refreshAccessToken;

@end
