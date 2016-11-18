//
//  CreditInformationViewController.m
//  li5
//
//  Created by gustavo hansen on 10/17/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import VMaskTextField;
@import Stripe;
@import Li5Api;
@import MBProgressHUD;

#import "PaymentInfoViewController.h"
#import "CVVHelpViewController.h"
#import "ShippingInfoViewController.h"
#import "UIImage+Li5.h"
#import "AppDelegate.h"
#import "AddShippingInfoViewController.h"

@interface PaymentInfoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet VMaskTextField *creditCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *creditCardName;
@property (weak, nonatomic) IBOutlet VMaskTextField *ccExpiration;
@property (weak, nonatomic) IBOutlet VMaskTextField *ccCvv;
@property (weak, nonatomic) IBOutlet UITextField *alias;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonBottom;
@property (nonatomic) Card *currentCard;
@property (strong, nonatomic) CardIOCreditCardInfo *cardInfo;
@property (strong, nonatomic) STPToken *token;

@property (weak, nonatomic) UITextField *activeTextField;

@end

@implementation PaymentInfoViewController

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    
    self.title = [@"Payments" uppercaseString];
    self.navigationController.navigationBar.topItem.title = @"";
    
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
    self.ccCvv.inputAccessoryView = nextKeyboardToolbar;
    self.ccExpiration.inputAccessoryView = nextKeyboardToolbar;
    
    nextKeyboardToolbar.items = @[spaceItem, nextItem];
    [nextKeyboardToolbar sizeToFit];
    self.creditCardNumber.inputAccessoryView = nextKeyboardToolbar;
    
    self.alias.inputAccessoryView = keyboardToolbar;
    self.creditCardName.inputAccessoryView = nextKeyboardToolbar;
    
    [self.saveButton setBackgroundImage:[UIImage imageWithColor:[UIColor li5_redColor] andRect:self.saveButton.bounds] forState:UIControlStateNormal];
    [self.saveButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] andRect:self.saveButton.bounds] forState:UIControlStateDisabled];
    [self.saveButton setEnabled:NO];
    
    if(_currentCard != nil) {
    
        self.ccExpiration.text = [NSString stringWithFormat:@"%@/%@", _currentCard.expirationMonth, _currentCard.expirationYear];
        self.creditCardName.text = _currentCard.name;
        self.creditCardName.enabled = false;
        self.creditCardNumber.text = [NSString stringWithFormat:@"**** **** **** %@", _currentCard.last4];
        self.alias.text = _currentCard.alias;
        
        UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(delete)];
        self.navigationItem.rightBarButtonItem = delete;
    }
}

- (void) delete {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [[Li5ApiHandler sharedInstance] deleteCard:_currentCard completion:^(NSError *error) {
        [hud hideAnimated:YES];
        
        if (error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.description
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
        }else {
            Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
            [flowController updateUserProfile];
            
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                
                if([controller.restorationIdentifier isEqualToString:@"paymentEmptyVC"]){
                    
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
        }
    }];
}

- (void) setCurrentCard:(Card *) card {
    _currentCard = card;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CardIOUtilities preload];
    self.title = [@"Payments" uppercaseString];
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
    
    AddShippingInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingInfoVC"];
    
    if(_currentCard != nil) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        
        _currentCard.expirationMonth = [[NSNumber alloc] initWithInt:[expArr.firstObject intValue]];
        
        ;
        _currentCard.expirationYear = [[NSNumber alloc] initWithInt:[expArr.lastObject intValue]];
        
        _currentCard.cvv = self.ccCvv.text;
        [[Li5ApiHandler sharedInstance]
                      updateCreditCard:self.currentCard
                      completion:^(NSError *error) {
                         [hud hideAnimated:YES];
                         if (error)
                         {
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                             message:error.userInfo[@"error"][@"message"]
                                                                            delegate:self
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil];
                             [alert show];
                         }
                         else
                         {
                             [vc setCurrentAddress:_currentCard.address];
                             
                             [self.navigationController popViewControllerAnimated:YES];
                         }
                     }];
        
    }
    else {
        
        STPCardParams *cardParams = [[STPCardParams alloc] init];
        cardParams.number = self.cardInfo != nil && [self.cardInfo.cardNumber isEqualToString:self.creditCardNumber.text]? self.cardInfo.cardNumber:self.creditCardNumber.text;
        cardParams.expMonth = [expArr.firstObject integerValue];
        cardParams.expYear = [expArr.lastObject integerValue];
        cardParams.cvc = self.ccCvv.text;
        cardParams.name = self.creditCardName.text;
        
        [vc setCreditCardParams:cardParams];
        [vc setCreditCardAlias:self.alias.text];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//                        [self.navigationController popViewControllerAnimated:YES];
//    [self generateStripeToken:^(NSError *error) {
//        if (error)
//        {
//            [hud hideAnimated:YES];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                            message:error.description
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        }
//        else
//        {
//            [[Li5ApiHandler sharedInstance]
//             updateUserWihCreditCard:self.token.tokenId
//             alias: self.alias.text
//             completion:^(NSError *error) {
//                [hud hideAnimated:YES];
//                if (error)
//                {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                    message:error.userInfo[@"error"][@"message"]
//                                                                   delegate:self
//                                                          cancelButtonTitle:@"OK"
//                                                          otherButtonTitles:nil];
//                    [alert show];
//                }
//                else
//                {
//                    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
//                    [flowController updateUserProfile];
//                    
//                    [self.navigationController popViewControllerAnimated:YES];
//                }
//            }];
//        }
//    }];
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
    if (self.activeTextField.tag < 5)
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
    
    self.saveButton.enabled = [self isFormValid];
}

- (BOOL)isFormValid
{
    for (UITextField *field in @[self.creditCardNumber, self.creditCardName, self.ccExpiration, self.ccCvv, self.alias]) {
        if (field.text.length == 0)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self next:textField];
    return true;
}
- (IBAction)back:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

@end
