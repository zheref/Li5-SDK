//
//  OnboardingPageContentViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/30/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "OnboardingPageContentViewController.h"

@interface OnboardingPageContentViewController ()

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation OnboardingPageContentViewController

@dynamic pageIndex;

#pragma mark - UI Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = self.titleText;
    self.subtitleLabel.text = self.subtitleText;
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
