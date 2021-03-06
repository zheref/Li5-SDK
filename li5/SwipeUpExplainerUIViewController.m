//
//  SwipeUpExplainerUIViewController.m
//  li5
//
//  Created by Martin Cocaro on 7/27/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "SwipeUpExplainerUIViewController.h"
#import "Li5Constants.h"

@implementation SwipeUpExplainerUIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)cardDismissed
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:TRUE forKey:kLi5SwipeUpExplainerViewPresented];
}

@end
