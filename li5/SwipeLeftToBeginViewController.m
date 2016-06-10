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

- (IBAction)swipeDetected:(UIPanGestureRecognizer*)sender
{
    DDLogVerbose(@"");
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self dismissViewControllerAnimated:NO completion:^{
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:TRUE forKey:kLi5SwipeLeftExplainerViewPresented];
        }];
    }
}

@end
