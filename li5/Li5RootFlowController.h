//
//  RootViewController.h
//  li5
//
//  Created by Martin Cocaro on 1/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import Li5Api;

@interface Li5RootFlowController : NSObject

@property (nonatomic, strong) Profile *userProfile;

- (instancetype)initWithNavigationController:(UINavigationController *)navController;

- (void)showInitialScreen;

- (void)showOnboardingScreen;

- (void)showCategoriesSelectionScreen;

- (void)showPrimeTimeScreen;

- (void)showExploreScreen;

- (void)showProfileScreen;

- (void)showSettingsScreen;

- (void)updateUserProfile;

@end
