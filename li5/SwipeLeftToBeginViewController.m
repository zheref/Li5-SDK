//
//  SwipeLeftToBeginViewController.m
//  li5
//
//  Created by Martin Cocaro on 6/8/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
#import "Li5Constants.h"
#import "SwipeLeftToBeginViewController.h"

@interface SwipeLeftToBeginViewController ()

@end

@implementation SwipeLeftToBeginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self doTurnOnNotifications];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)doTurnOnNotifications {
    
}

- (void)cardDismissed
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:TRUE forKey:kLi5SwipeLeftExplainerViewPresented];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kPrimeTimeReadyToStart object:nil];
}

@end
