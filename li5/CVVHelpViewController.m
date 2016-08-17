//
//  CVVHelpViewController.m
//  li5
//
//  Created by Martin Cocaro on 7/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "CVVHelpViewController.h"

@implementation CVVHelpViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
