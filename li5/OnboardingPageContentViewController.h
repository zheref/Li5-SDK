//
//  OnboardingPageContentViewController.h
//  li5
//
//  Created by Martin Cocaro on 5/30/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import BCVideoPlayer;

@interface OnboardingPageContentViewController : UIViewController <BCPlayerDelegate>

@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *subtitleText;
@property (nonatomic, strong) NSURL *videoUrl;

@end
