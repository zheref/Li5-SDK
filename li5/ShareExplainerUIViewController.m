//
//  ShareExplainerUIViewController.m
//  li5
//
//  Created by Martin Cocaro on 12/29/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "ShareExplainerUIViewController.h"

@interface ShareExplainerUIViewController ()

@property (weak, nonatomic) IBOutlet CardUIView *card;

@end

@implementation ShareExplainerUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.delegate) {
        self.card.delegate = self.delegate;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
