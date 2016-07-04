//
//  Li5Constants.h
//  li5
//
//  Created by Martin Cocaro on 6/8/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
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

//User Defaults Keys
extern NSString * const kLi5UserID;
extern NSString * const kLi5CategoriesSelectionViewPresented;
extern NSString * const kLi5SwipeLeftExplainerViewPresented;
extern NSString * const kLi5SwipeDownExplainerViewPresented;

@end
