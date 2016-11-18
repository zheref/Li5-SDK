//
//  CheckoutViewController.m
//  li5
//
//  Created by Martin Cocaro on 7/25/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import VMaskTextField;
@import Stripe;
@import Li5Api;
@import MBProgressHUD;

#import "CheckoutViewController.h"
#import "CVVHelpViewController.h"
#import "ShippingInfoViewController.h"
#import "UIImage+Li5.h"
#import "AppDelegate.h"

@interface CheckoutViewController ()

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet VMaskTextField *creditCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *creditCardName;
@property (weak, nonatomic) IBOutlet VMaskTextField *ccExpiration;
@property (weak, nonatomic) IBOutlet VMaskTextField *ccCvv;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonBottom;

@property (strong, nonatomic) CardIOCreditCardInfo *cardInfo;
@property (strong, nonatomic) STPToken *token;

@property (weak, nonatomic) UITextField *activeTextField;

@end

@implementation CheckoutViewController

@synthesize product;

#pragma mark - View Setup

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    
    self.creditCardNumber.mask = @"#### #### #### ####";
    self.ccExpiration.mask = @"##/##";
    self.ccCvv.mask = @"####";
    
    [self.scanButton setImage:[[UIImage imageNamed:@"creditcard"] blackAndWhiteImage] forState:UIControlStateDisabled];
    
    // Hide your "Scan Card" button, or take other appropriate action...
    self.scanButton.enabled = [CardIOUtilities canReadCardWithCamera];
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    
    UIToolbar *nextKeyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height)];
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(next:)];
    
    keyboardToolbar.items = @[spaceItem,doneItem];
    [keyboardToolbar sizeToFit];
    self.ccCvv.inputAccessoryView = keyboardToolbar;
    self.ccExpiration.inputAccessoryView = keyboardToolbar;
    
    nextKeyboardToolbar.items = @[spaceItem, nextItem];
    [nextKeyboardToolbar sizeToFit];
    self.creditCardNumber.inputAccessoryView = nextKeyboardToolbar;
    
    [self.continueButton setBackgroundImage:[UIImage imageWithColor:[UIColor li5_redColor] andRect:self.continueButton.bounds] forState:UIControlStateNormal];
    [self.continueButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] andRect:self.continueButton.bounds] forState:UIControlStateDisabled];
    [self.continueButton setEnabled:NO];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

//- (void)keyboardWillChange:(NSNotification*)notification
//{
//    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    int curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
//    CGRect curFrame = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGRect targetFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//
//    double deltaY = targetFrame.origin.y - curFrame.origin.y;
//
//    self.continueButtonBottom.constant = deltaY;
//    DDLogVerbose(@"deltaY: %f",deltaY);
//    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
//        [self.view layoutIfNeeded];
//    } completion:nil];
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CardIOUtilities preload];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)back:(id)sender
{
    DDLogVerbose(@"");
    if (self.navigationController.viewControllers.count < 3)
    {
        CATransition *outTransition = [CATransition animation];
        outTransition.duration = 0.3;
        outTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        outTransition.type = kCATransitionPush;
        outTransition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:outTransition forKey:kCATransition];
    }
    
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (IBAction)scanCreditCard:(id)sender
{
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    scanViewController.hideCardIOLogo = YES;
    scanViewController.keepStatusBarStyle = YES;
    scanViewController.guideColor = [UIColor li5_redColor];
    scanViewController.suppressScanConfirmation = YES;
    scanViewController.collectExpiry = YES;
    scanViewController.collectCVV = YES;
    scanViewController.collectCardholderName = YES;
    scanViewController.disableManualEntryButtons = YES;
    [self presentViewController:scanViewController animated:YES completion:nil];
}

- (IBAction)showCVVHelp:(id)sender
{
    CVVHelpViewController *helpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cvvHelpView"];
    [self presentViewController:helpVC animated:NO completion:nil];
}

- (IBAction)goNext:(id)sender
{
    if (![self isFormValid]) return;
    
    NSArray<NSString*> *expArr = [self.ccExpiration.text componentsSeparatedByString:@"/"];
    
    STPCardParams *cardParams = [[STPCardParams alloc] init];
    cardParams.number = self.cardInfo != nil && [self.cardInfo.cardNumber isEqualToString:self.creditCardNumber.text]? self.cardInfo.cardNumber:self.creditCardNumber.text;
    cardParams.expMonth = [expArr.firstObject integerValue];
    cardParams.expYear = [expArr.lastObject integerValue];
    cardParams.cvc = self.ccCvv.text;
    cardParams.name = self.creditCardName.text;
    
#if DEBUG
    cardParams = [self getTestingCard];
#endif
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    [self generateStripeTokenWithParams:cardParams completion:^(NSError *error) {
        [hud hideAnimated:YES];
        
        if (error)
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.description
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            
            ShippingInfoViewController *shippingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"shippingView"];
            [shippingVC setProduct:self.product];
            [shippingVC setShowSameAsBillingAddress:true];
            [shippingVC setCreditCardParams:cardParams];
            [self.navigationController pushViewController:shippingVC animated:YES];
        }
    }];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    DDLogVerbose(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    DDLogVerbose(@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv);
    
    self.cardInfo = info;
    
    // Use the card info...
    if (info.redactedCardNumber)
    {
        self.creditCardNumber.text = info.redactedCardNumber;
    }
    
    if (info.cardholderName)
    {
        self.creditCardName.text = info.cardholderName;
    }
    if (info.expiryMonth)
    {
        self.ccExpiration.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)info.expiryMonth,(unsigned long)info.expiryYear];
    }
    if (info.cvv)
    {
        self.ccCvv.text = info.cvv;
    }
    
    [scanViewController dismissViewControllerAnimated:NO completion:^{
        [self.creditCardName becomeFirstResponder];
    }];
}

- (void)done:(id)sender
{
    DDLogVerbose(@"%@",sender);
    [self.activeTextField resignFirstResponder];
}

- (void)next:(id)sender
{
    if (self.activeTextField.tag < 3)
    {
        [[self.view viewWithTag:self.activeTextField.tag+1] becomeFirstResponder];
    }
    else
    {
        [self.activeTextField resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [textField isKindOfClass:[VMaskTextField class]])
    {
        VMaskTextField * maskTextField = (VMaskTextField*) textField;
        return  [maskTextField shouldChangeCharactersInRange:range replacementString:string];
    }
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    DDLogVerbose(@"");
    self.activeTextField = nil;
    
    self.continueButton.enabled = [self isFormValid];
}

- (BOOL)isFormValid
{
    for (UITextField *field in @[self.creditCardNumber, self.creditCardName, self.ccExpiration, self.ccCvv]) {
        if (field.text.length == 0)
        {
            return NO;
        }
    }
    return YES;
}

- (void)generateStripeTokenWithParams:(STPCardParams *)cardParams completion:(void (^)(NSError *error))completion
{
    __weak typeof(self) welf = self;
    [[STPAPIClient sharedClient] createTokenWithCard:cardParams completion:^(STPToken *token, NSError *error) {
        __strong typeof(welf) swelf = welf;
        if (error) {
            // show the error, maybe by presenting an alert to the user
            DDLogError(@"error while validating card: %@", error.localizedDescription);
            completion(error);
        } else {
            swelf.token = token;
            if (completion!=nil)
            {
                completion(nil);
            }
        }
    }];
}

- (STPCardParams*)getTestingCard
{
    STPCardParams *cardParams = [[STPCardParams alloc] init];
    cardParams.number = @"4242 4242 4242 4242";
    cardParams.expMonth = 12;
    cardParams.expYear = 2021;
    cardParams.cvc = @"1234";
    cardParams.name = @"Robert B Cool";
    return cardParams;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self next:textField];
    return true;
}

@end
