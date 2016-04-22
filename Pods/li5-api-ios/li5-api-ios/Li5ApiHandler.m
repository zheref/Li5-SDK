//
//  li5_api_ios.m
//  li5-api-ios
//
//  Created by Leandro Fournier on 4/12/16.
//  Copyright © 2016 Leandro Fournier. All rights reserved.
//

#import "Li5ApiHandler.h"
#import "Categories.h"
#import "Profiles.h"

@implementation Li5ApiHandler

+ (Li5ApiHandler *)sharedInstance {
    static Li5ApiHandler *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[Li5ApiHandler alloc] init];
        }
    }
    return sharedInstance;
}

- (void)login:(NSString *)user withPassword:(NSString *)password withCompletion:(void (^)(NSError *error))completion {
    
    NSURLSession *session = [self createSession];
    
    NSURL *url = [self urlForEndpoint:Li5API_ENDPOINT_GET_ACCESS_TOKEN];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0"}];
    NSDictionary *parametersDict = @{   @"type": @"userpassword",
                                        @"user": user,
                                        @"password": password};
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error == nil) {
        [urlRequest setHTTPBody:json];
    } else {
        completion(error);
    }
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(error);
        } else if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]]);
        } else {
            NSError *serializationError;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError == nil) {
                [SSKeychain setPassword:[jsonDict objectForKey:@"refresh_token"] forService:Li5API_SERVICE account:user];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:user forKey:Li5API_USERDEFAULTS_KEY_USER];
                [userDefaults setObject:[jsonDict objectForKey:@"access_token"] forKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN];
                [userDefaults setObject:[NSDate dateWithTimeIntervalSinceNow:[[jsonDict objectForKey:@"expires_in"] integerValue]] forKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN_EXPIRATION_DATE];
                [userDefaults synchronize];
                
                completion(nil);
            } else {
                completion(serializationError);
            }
        }
    }];
    
    [dataTask resume];
}

- (void)login:(NSString *)user withFacebookToken:(NSString *)token withCompletion:(void (^)(NSError *error))completion {
    
    NSURLSession *session = [self createSession];
    
    NSURL *url = [self urlForEndpoint:Li5API_ENDPOINT_GET_ACCESS_TOKEN];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *parametersDict = @{   @"type": @"facebook",
                                        @"access_token": token};
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json",
                                            @"version": @"1.0"}];
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error == nil) {
        [urlRequest setHTTPBody:json];
    } else {
        completion(error);
    }
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(error);
        } else if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]]);
        } else {
            NSError *serializationError;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError == nil) {
                [SSKeychain setPassword:[jsonDict objectForKey:@"refresh_token"] forService:Li5API_SERVICE account:user];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:user forKey:Li5API_USERDEFAULTS_KEY_USER];
                [userDefaults setObject:[jsonDict objectForKey:@"access_token"] forKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN];
                [userDefaults setObject:[NSDate dateWithTimeIntervalSinceNow:[[jsonDict objectForKey:@"expires_in"] integerValue]] forKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN_EXPIRATION_DATE];
                [userDefaults synchronize];
                
                completion(nil);
            } else {
                completion(serializationError);
            }
        }
    }];
    
    [dataTask resume];
}

- (void)refreshAccessTokenWithCompletion:(void (^)(NSError *error))completion {
    
    NSURLSession *session = [self createSession];
    
    NSURL *url = [self urlForEndpoint:Li5API_ENDPOINT_REFRESH_TOKEN];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0",
                                            @"Authorization": [NSString stringWithFormat:@"Bearer %@", [self refreshAccessToken]]}];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(error);
        } else if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]]);
        } else {
            NSError *serializationError;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError == nil) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[jsonDict objectForKey:@"access_token"] forKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN];
                [userDefaults setObject:[NSDate dateWithTimeIntervalSinceNow:[[jsonDict objectForKey:@"expires_in"] integerValue]] forKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN_EXPIRATION_DATE];
                [userDefaults synchronize];
                
                completion(nil);
            } else {
                completion(serializationError);
            }
        }
    }];
    
    [dataTask resume];
}

- (BOOL)isAccessTokenAboutToBeingRevoked {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:[self accessTokenExpirationDate]];
    if (timeInterval > Li5API_ACCESS_TOKEN_SECONDS_LEFT_TO_BE_REFRESHED * -1) {
        return true;
    } else {
        return false;
    }
}

- (void)checkAccessTokenAvailabilityAndPerform:(void (^)(NSError *error))block {
    if ([self isAccessTokenAboutToBeingRevoked]) {
        [self refreshAccessTokenWithCompletion:^(NSError *error) {
            if (error == nil) {
                block(nil);
            } else {
                block(error);
            }
        }];
    } else {
        block(nil);
    }
}

- (void)revokeRefreshAccessTokenWithCompletion:(void (^)(NSError *error))completion {
    
    [self checkAccessTokenAvailabilityAndPerform:^(NSError *error) {
        if (error == nil) {
            NSURLSession *session = [self createSession];
            
            NSURL *url = [[self urlForEndpoint:Li5API_ENDPOINT_REVOKE_REFRESH_ACCESS_TOKEN] URLByAppendingPathComponent:[self refreshAccessToken]];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"DELETE"];
            [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0",
                                                    @"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    completion(error);
                } else if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]]);
                } else {
                    [SSKeychain deletePasswordForService:Li5API_SERVICE account:[self user]];
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults removeObjectForKey:Li5API_USERDEFAULTS_KEY_USER];
                    [userDefaults removeObjectForKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN];
                    [userDefaults removeObjectForKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN_EXPIRATION_DATE];
                    [userDefaults synchronize];
                    
                    completion(nil);
                }
            }];
            
            [dataTask resume];
        } else {
            completion(error);
        }
    }];
}

- (void)requestDiscoverProductsWithCompletion:(void (^)(NSError *error, NSArray <Product *> *products))completion {
    
    [self checkAccessTokenAvailabilityAndPerform:^(NSError *error) {
        if (error == nil) {
            NSURLSession *session = [self createSession];
            
            NSURL *url = [self urlForEndpoint:Li5API_ENDPOINT_DISCOVER_PRODUCTS];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"GET"];
            [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0",
                                                    @"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    completion(error, nil);
                } else if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]], nil);
                } else {
                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSError *jsonError = nil;
                    Products *products = [[Products alloc] initWithString:jsonString error:&jsonError];
                    if (jsonError == nil) {
                        completion(nil, products.data);
                    } else {
                        completion(jsonError, nil);
                    }
                }
            }];
            
            [dataTask resume];
        } else {
            completion(error, nil);
        }
    }];
}

- (void)requestCategoriesWithCompletion:(void (^)(NSError *error, NSArray<Category *> *categories))completion {
    
    [self checkAccessTokenAvailabilityAndPerform:^(NSError *error) {
        if (error == nil) {
            NSURLSession *session = [self createSession];
            
            NSURL *url = [self urlForEndpoint:Li5API_ENDPOINT_GET_CATEGORIES];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"GET"];
            [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0",
                                                    @"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    completion(error, nil);
                } else if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]], nil);
                } else {
                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSError *jsonError = nil;
                    Categories *categories = [[Categories alloc] initWithString:jsonString error:&jsonError];
                    if (jsonError == nil) {
                        completion(nil, categories.data);
                    } else {
                        completion(jsonError, nil);
                    }
                }
            }];
            
            [dataTask resume];
        } else {
            completion(error, nil);
        }
    }];
}

- (void)requestProfile:(void (^)(NSError *error, Profile *profile))completion {
    [self checkAccessTokenAvailabilityAndPerform:^(NSError *error) {
        if (error == nil) {
            NSURLSession *session = [self createSession];
            
            NSURL *url = [self urlForEndpoint:Li5API_ENDPOINT_PROFILE];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"GET"];
            [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0",
                                                    @"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    completion(error, nil);
                } else if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]], nil);
                } else {
                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSError *jsonError = nil;
                    Profiles *profiles = [[Profiles alloc] initWithString:jsonString error:&jsonError];
                    if (jsonError == nil) {
                        completion(nil, profiles.data);
                    } else {
                        completion(jsonError, nil);
                    }
                }
            }];
            
            [dataTask resume];
        } else {
            completion(error, nil);
        }
    }];
}

- (void)changeUserProfileWithCategoriesIDs:(NSArray *)categories withCompletion:(void (^)(NSError *error))completion {
    [self checkAccessTokenAvailabilityAndPerform:^(NSError *error) {
        if (error == nil) {
            NSURLSession *session = [self createSession];
            
            NSURL *url = [self urlForEndpoint:Li5API_ENDPOINT_PROFILE];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"PATCH"];
            [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0",
                                                    @"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
            NSDictionary *parametersDict = @{   @"preferences": categories};
            NSError *error = nil;
            NSData *json = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&error];
            if (error == nil) {
                [urlRequest setHTTPBody:json];
            } else {
                completion(error);
            }
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]]);
                } else {
                    completion(error);
                }
            }];
            
            [dataTask resume];
        } else {
            completion(error);
        }
    }];
}

- (void)postUserWatchedVideoWithId:(NSString *)product_id during:(NSNumber *)seconds withCompletion:(void (^)(NSError *error))completion {
    [self checkAccessTokenAvailabilityAndPerform:^(NSError *error) {
        if (error == nil) {
            NSURLSession *session = [self createSession];
            
            NSURL *url = [self urlForEndpoint:Li5API_ENDPOINT_DISCOVER_PRODUCTS];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0",
                                                    @"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
            NSDictionary *parametersDict = @{   @"product_id": product_id,
                                                @"time_viewed": seconds};
            NSError *error = nil;
            NSData *json = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&error];
            if (error == nil) {
                [urlRequest setHTTPBody:json];
            } else {
                completion(error);
            }
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]]);
                } else {
                    completion(error);
                }
            }];
            
            [dataTask resume];
        } else {
            completion(error);
        }
    }];
}

- (void)postLoveForProductWithSlug:(NSString *)productSlug withCompletion:(void (^)(NSError *error))completion {
    [self checkAccessTokenAvailabilityAndPerform:^(NSError *error) {
        if (error == nil) {
            NSURLSession *session = [self createSession];
            
            NSURL *url = [self urlForEndpoint:[Li5API_ENDPOINT_LOVE stringByReplacingOccurrencesOfString:@"{slug}" withString:productSlug]];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0",
                                                    @"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]]);
                } else {
                    completion(error);
                }
            }];
            
            [dataTask resume];
        } else {
            completion(error);
        }
    }];
}

- (void)deleteLoveForProductWithSlug:(NSString *)productSlug withCompletion:(void (^)(NSError *error))completion {
    [self checkAccessTokenAvailabilityAndPerform:^(NSError *error) {
        if (error == nil) {
            NSURLSession *session = [self createSession];
            
            NSURL *url = [self urlForEndpoint:[Li5API_ENDPOINT_LOVE stringByReplacingOccurrencesOfString:@"{slug}" withString:productSlug]];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"DELETE"];
            [urlRequest setAllHTTPHeaderFields:@{   @"Accept": @"application/vnd.api+json; version=1.0",
                                                    @"Authorization": [NSString stringWithFormat:@"Bearer %@", [self accessToken]]}];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if ([(NSHTTPURLResponse *)response statusCode] >= 400) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    completion([NSError errorWithDomain:[[httpResponse URL] absoluteString] code:[httpResponse statusCode] userInfo:[httpResponse allHeaderFields]]);
                } else {
                    completion(error);
                }
            }];
            
            [dataTask resume];
        } else {
            completion(error);
        }
    }];
}

- (NSString *)user {
    return [[NSUserDefaults standardUserDefaults] objectForKey:Li5API_USERDEFAULTS_KEY_USER];
}

- (NSString *)accessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN];
}

- (NSDate *)accessTokenExpirationDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:Li5API_USERDEFAULTS_KEY_ACCESS_TOKEN_EXPIRATION_DATE];
}

- (NSString *)refreshAccessToken {
    return [SSKeychain passwordForService:Li5API_SERVICE account:[self user]];
}

#pragma mark - Private Methods

- (NSURLSession *)createSession {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    return defaultSession;
}

- (NSURL *)urlForEndpoint:(NSString *)endpoint {
    return [NSURL URLWithString:[_baseURL stringByAppendingPathComponent:endpoint]];
}

@end
