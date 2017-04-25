//
//  Li5UINavigationController.m
//  li5
//
//  Created by Martin Cocaro on 1/13/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

#import "Li5UINavigationController.h"

@interface Li5UINavigationController ()

@end

@implementation Li5UINavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden {
    return [self.topViewController prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    DDLogVerbose(@"");
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    DDLogVerbose(@"");
    return self.topViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
