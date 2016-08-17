//
//  OrderProcessedViewController.m
//  li5
//
//  Created by Martin Cocaro on 7/28/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;
@import MMMaterialDesignSpinner;

#import "OrderProcessedViewController.h"
#import "Li5RootFlowController.h"
#import "AppDelegate.h"

@interface OrderProcessedViewController ()

@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@property (weak, nonatomic) IBOutlet UIView *orderView;
@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UILabel *productBrand;
@property (weak, nonatomic) IBOutlet UILabel *orderStatus;
@property (weak, nonatomic) IBOutlet UILabel *priceCharged;
@property (weak, nonatomic) IBOutlet UILabel *creditCardCharged;
@property (weak, nonatomic) IBOutlet UILabel *shippingInfo;

@end

@implementation OrderProcessedViewController

@synthesize product;

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

#pragma mark - View Setup

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
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
//            if (!userProfile.is_verified)
//            {
//                [[Li5ApiHandler sharedInstance] requestUserEmailVerificationWithCompletion:^(NSError *error) {
//                    if (error)
//                    {
//                        DDLogError(@"error %@",error.debugDescription);
//                    }
//                    else
//                    {
//                    }
//                }];
//            }
//            else
//            {
                [self performBuyAction];
//            }
        }
    }
    else
    {
        [self updateOrderDetails];
    }
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

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
}

#pragma mark - User Actions

- (IBAction)continueShopping:(id)sender
{
    DDLogVerbose(@"");
    CATransition *outTransition = [CATransition animation];
    outTransition.duration = 0.3;
    outTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    outTransition.type = kCATransitionPush;
    outTransition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:outTransition forKey:kCATransition];

    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Private Methods

- (void)performBuyAction
{
    self.orderView.hidden = YES;
    self.errorView.hidden = YES;
    [[Li5ApiHandler sharedInstance] createOrderWithProduct:self.product.id quantity:@(1) card:nil shippingAddress:nil completion:^(NSError *error, Order *newOrder) {
        [_spinnerView stopAnimating];
        
        if (error)
        {
            self.errorMessage.text = error.userInfo[@"errors"][@"message"];
            self.errorView.hidden = NO;
            self.orderView.hidden = YES;
        }
        else
        {
            self.errorView.hidden = YES;
            self.orderView.hidden = NO;
            self.order = newOrder;
            [self updateOrderDetails];
        }
    }];
}

- (void)updateOrderDetails
{
    self.productTitle.text = self.order.product.title;
    self.productBrand.text = self.order.product.brand;
    self.orderStatus.text = self.order.status;
//    self.creditCardCharged.text = self.order.cre
    self.priceCharged.text = [NSString stringWithFormat:@"$%.00f",([self.order.total doubleValue] / 100)];
    self.shippingInfo.text = [NSString stringWithFormat:@"%@ ,%@ (%@)",self.order.shippingAddress.address1,self.order.shippingAddress.city, self.order.shippingAddress.zip];
}

@end
