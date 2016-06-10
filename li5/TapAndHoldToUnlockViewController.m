//
//  TapAndHoldToUnlockViewController.m
//  li5
//
//  Created by Martin Cocaro on 6/7/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "TapAndHoldToUnlockViewController.h"

@implementation TapAndHoldToUnlockViewController

- (BOOL)prefersStatusBarHidden
{
    return TRUE;
}

- (IBAction)userDidTap:(UITapGestureRecognizer*)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
