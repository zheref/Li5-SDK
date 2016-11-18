//
//  ShippingInfoEmptyViewController.m
//  li5
//
//  Created by gustavo hansen on 10/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ShippingInfoEmptyViewController.h"
#import "AddShippingInfoViewController.h"
#import "Li5RootFlowController.h"
#import "AppDelegate.h"

@interface ShippingInfoEmptyViewController ()

@end

@implementation ShippingInfoEmptyViewController

- (void)viewDidLoad {
    DDLogVerbose(@"");
    
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.topItem.title = @"";
//    
//        Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
//        Profile *userProfile = [flowController userProfile];
//    
//        if (userProfile)
//        {
//            if (userProfile.defaultAddress != nil) {
//                UIViewController *viewController= [self.storyboard instantiateViewControllerWithIdentifier:@"shippingInfoVC"];
//                [self.navigationController pushViewController:viewController animated:YES];
//            }
//        }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = [@"Shipping Info" uppercaseString];
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    Profile *userProfile = [flowController userProfile];
    
    if (userProfile)
    {
        if (userProfile.defaultAddress != nil) {
            UIViewController *viewController= [self.storyboard instantiateViewControllerWithIdentifier:@"shippingInfoVC"];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addShippingInfo:(id)sender {

    AddShippingInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingInfoVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
