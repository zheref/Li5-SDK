//
//  PaymentEmptyViewController.m
//  li5
//
//  Created by gustavo hansen on 10/17/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "PaymentEmptyViewController.h"
#import "PaymentInfoViewController.h"
#import "Li5RootFlowController.h"
#import "AppDelegate.h"

@interface PaymentEmptyViewController ()

@end

@implementation PaymentEmptyViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    self.title = [@"Payments" uppercaseString];
    self.navigationController.navigationBar.topItem.title = @"";
}


//paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentInfoSelectVC"];
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     self.title = [@"Payments" uppercaseString];
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    Profile *userProfile = [flowController userProfile];
    
    if (userProfile)
    {
        if (userProfile.defaultCard != nil) {
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
}

- (IBAction)addPayment:(id)sender {
    
    PaymentInfoViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
    
    [self.navigationController pushViewController:paymentVC animated:YES];
}

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
