//
//  Li5Constants.h
//  li5
//
//  Created by Martin Cocaro on 6/8/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Li5Constants : NSObject

//Events
extern NSString * const kLoginSuccessful;
extern NSString * const kLoginFailed;
extern NSString * const kLogoutSuccessful;
extern NSString * const kLogoutFailed;
extern NSString * const kCategoriesUpdateSuccessful;
extern NSString * const kCategoriesUpdateFailed;
extern NSString * const kPrimeTimeLoaded;
extern NSString * const kPrimeTimeFailedToLoad;
extern NSString * const kPrimeTimeReadyToStart;
extern NSString * const kPrimeTimeExpired;
extern NSString * const kProfileUpdated;
extern NSString * const kLoggedOutFromServer;
extern NSString * const kUserSettingsUpdated;

//User Defaults Keys
extern NSString * const kLi5UserID;
extern NSString * const kLi5CategoriesSelectionViewPresented;
extern NSString * const kLi5SwipeLeftExplainerViewPresented;
extern NSString * const kLi5SwipeDownExplainerViewPresented;
extern NSString * const kLi5SwipeUpExplainerViewPresented;
extern NSString * const kLi5ShareToken;
extern NSString * const kLi5Product;
extern NSString * const kLi5ShareExplainerViewPresented;

@end
