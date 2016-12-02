//
//  SwipeDownToExploreViewController.m
//  li5
//
//  Created by Martin Cocaro on 6/8/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "SwipeDownToExploreViewController.h"
#import "Li5Constants.h"

@interface SwipeDownToExploreViewController ()

@end

@implementation SwipeDownToExploreViewController

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
}

#pragma mark - UI Setup

- (BOOL)prefersStatusBarHidden
{
    return TRUE;
}

#pragma mark - Gesture Recognizers

- (IBAction)swipeDetected:(UIPanGestureRecognizer*)sender
{
    DDLogVerbose(@"");
    if (self.searchInteractor)
    {
        [self.searchInteractor userDidPan:sender];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self dismissViewControllerAnimated:NO completion:^{
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:TRUE forKey:kLi5SwipeDownExplainerViewPresented];
        }];
    }
}

@end
