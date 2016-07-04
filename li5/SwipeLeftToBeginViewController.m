//
//  SwipeLeftToBeginViewController.m
//  li5
//
//  Created by Martin Cocaro on 6/8/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
#import "Li5Constants.h"
#import "SwipeLeftToBeginViewController.h"

@interface SwipeLeftToBeginViewController ()

@end

@implementation SwipeLeftToBeginViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)cardDismissed
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:TRUE forKey:kLi5SwipeLeftExplainerViewPresented];
}

@end
