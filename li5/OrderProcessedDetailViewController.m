//
//  OrderProcessedDetailViewController.m
//  li5
//
//  Created by gustavo hansen on 11/24/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "OrderProcessedDetailViewController.h"

@interface OrderProcessedDetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *shippingInfo;
@property (weak, nonatomic) IBOutlet UILabel *orderStatus;
@property (weak, nonatomic) IBOutlet UILabel *priceCharged;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UILabel *productBrand;

@property (weak, nonatomic) IBOutlet UILabel *creditCardCharged;

@property (weak, nonatomic) IBOutlet CardUIView *card;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation OrderProcessedDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.card.delegate = self;
    self.productTitle.text = self.order.product.title;
    self.productBrand.text = self.order.product.brand;
    self.orderStatus.text = self.order.status;
    self.creditCardCharged.text = [NSString stringWithFormat:@"**** **** **** %@", self.order.card.last4];
    self.priceCharged.text = [NSString stringWithFormat:@"$%.00f",([self.order.total doubleValue] / 100)];
    self.shippingInfo.text = [NSString stringWithFormat:@"%@ ,%@ (%@)",self.order.shippingAddress.address1,self.order.shippingAddress.city, self.order.shippingAddress.zip];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)continueShopping:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - CardUIViewDelegate

- (void)cardDismissed
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

-(void)viewDidLayoutSubviews{
    
    [self.scrollV setContentSize:CGSizeMake(self.containerView.frame.size.width, 500)];
}


@end
