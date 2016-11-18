//
//  OrderSuccessViewController.m
//  li5
//
//  Created by gustavo hansen on 10/17/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "OrderProcessedViewController.h"
#import "Li5RootFlowController.h"
#import "AppDelegate.h"

@import MMMaterialDesignSpinner;

@interface OrderProcessedViewController ()

@property (weak, nonatomic) IBOutlet CardUIView *card;
//@property (weak, nonatomic) IBOutlet UIView *errorView;
//@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;

@end

@implementation OrderProcessedViewController

@synthesize product;

- (void)viewDidLoad {
    DDLogVerbose(@"");
    [super viewDidLoad];
    self.card.hidden = true;
    self.card.delegate = self;
    //Set product details on view
    
    if (self.order == nil)
    {
        // Initialize the progress view
        _spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0,0,80,80)];
        _spinnerView.lineWidth = 3.5f;
        _spinnerView.tintColor = [UIColor li5_whiteColor];
        _spinnerView.hidesWhenStopped = YES;
        [self.view addSubview:_spinnerView];
        [_spinnerView startAnimating];
        
        Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
        Profile *userProfile = [flowController userProfile];
        if (userProfile)
        {
//                        if (!userProfile.is_verified)
//                        {
//                            [[Li5ApiHandler sharedInstance] requestUserEmailVerificationWithCompletion:^(NSError *error) {
//                                if (error)
//                                {
//                                    DDLogError(@"error %@",error.debugDescription);
//                                }
//                                else
//                                {
//                                }
//                            }];
//                        }
//                        else
//                        {
                            [self performBuyAction];
//                        }
        }
    }
    else
    {
        [self performBuyAction];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)performBuyAction
{
    //    self.orderView.hidden = YES;
    //    self.errorView.hidden = YES;
        [[Li5ApiHandler sharedInstance] createOrderWithProduct:self.product.id quantity:@(1) card:nil shippingAddress:nil completion:^(NSError *error, Order *newOrder) {
            [_spinnerView stopAnimating];
    
            if (error)
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:error.userInfo[@"error"][@"message"]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self dismissViewControllerAnimated:YES completion:nil];
                
//                self.errorMessage.text = error.userInfo[@"errors"][@"message"];
//                self.errorView.hidden = NO;
//                self.orderView.hidden = YES;
            }
            else
            {
                self.card.hidden = false;
//                self.errorView.hidden = YES;
//                self.orderView.hidden = NO;
//                self.order = newOrder;
//                [self updateOrderDetails];
            }
        }];
}

- (void)updateViewConstraints
{
    DDLogVerbose(@"");
    [super updateViewConstraints];
    
    [_spinnerView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@(80));
        make.height.equalTo(@(80));
    }];
}

#pragma mark - CardUIViewDelegate

- (void)cardDismissed
{
    DDLogVerbose(@"");
    CATransition *outTransition = [CATransition animation];
    outTransition.duration = 0.3;
    outTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    outTransition.type = kCATransitionPush;
    outTransition.subtype = kCATransitionFromBottom;
    [self.parent.navigationController.view.layer addAnimation:outTransition forKey:kCATransition];
    
    [self.parent.navigationController popToRootViewControllerAnimated:NO];
}



@end
