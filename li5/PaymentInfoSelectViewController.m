//
//  PaymentInfoSelectViewController.m
//  li5
//
//  Created by gustavo hansen on 10/17/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import VMaskTextField;
@import MBProgressHUD;

#import "PaymentInfoSelectViewController.h"
#import "Li5RootFlowController.h"
#import "AppDelegate.h"
#import "PaymentInfoViewController.h"
#import "Li5ApiHandler.h"

@interface PaymentInfoSelectViewController ()

@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet VMaskTextField *creditCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *creditCardName;
@property (weak, nonatomic) IBOutlet VMaskTextField *ccExpiration;
@property (weak, nonatomic) IBOutlet VMaskTextField *ccCvv;
@property (weak, nonatomic) IBOutlet UITextField *alias;
@property (weak, nonatomic) IBOutlet UIButton *selectPaymentBtn;
@property Card * currentCard;
@property (weak, nonatomic) UITextField *activeTextField;
@property NSArray<Card *> *cards;
@end

@implementation PaymentInfoSelectViewController

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    
    self.title = [@"Payments" uppercaseString];
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.creditCardNumber.enabled = false;
    self.ccExpiration.enabled = false;
    self.creditCardName.enabled = false;
    self.ccCvv.enabled = false;
    self.alias.enabled = false;
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    
    Profile *userProfile = [flowController userProfile];
    
    if (userProfile)
    {
        Card *card = userProfile.defaultCard;
        self.currentCard = card;
        self.creditCardName.text = card.name;
        self.alias.text = card.alias;
        self.creditCardNumber.text = [NSString stringWithFormat: @"**** **** **** %@", card.last4];
        self.ccCvv.text = @"****";
        self.ccExpiration.text = [NSString stringWithFormat: @"%@/%@",card.expirationMonth,  [[card.expirationYear stringValue] substringFromIndex:2]];
    }
    
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    self.navigationItem.rightBarButtonItem = edit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)edit {
    
    PaymentInfoViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
    
    [paymentVC setCurrentCard:self.currentCard];
    [self.navigationController pushViewController:paymentVC animated:YES];
    
}

- (IBAction)editPayment:(id)sender {
    
}
- (IBAction)addOtherCreditCard:(id)sender {
    PaymentInfoViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
    
    [self.navigationController pushViewController:paymentVC animated:YES];
}

- (IBAction)selectPaymentMethod:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Card ending With"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (Card *card in self.cards) {
        
        NSString *alias = card.alias.length > 0 ? card.alias : card.issuer;
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: [NSString stringWithFormat: @"%@ **** %@", alias, card.last4]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self handlePaymentChange:card];
                                                       }];
        
        [alert addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel"
                                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                         
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         //TODO get card info
                                                     }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void) handlePaymentChange:(Card *)card {
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    [flowController updateUserProfile];
    
    self.creditCardName.text = card.name;
    self.alias.text = card.alias ;
    self.creditCardNumber.text = [NSString stringWithFormat: @"**** **** **** %@", card.last4];
    self.ccCvv.text = @"****";
    self.ccExpiration.text = [NSString stringWithFormat: @"%@/%@",
                              card.expirationMonth,  [[card.expirationYear stringValue] substringFromIndex:2]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = [@"Payments" uppercaseString];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [[Li5ApiHandler sharedInstance] requestUserCreditCardsWithCompletion:^(NSError *error, NSArray<Card *> *cards) {
        
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
            
            self.cards = cards;
        }
        
    }];
}

- (IBAction)back:(id)sender {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        if([controller.restorationIdentifier isEqualToString:@"userSettingsVC"]){
            
            [self.navigationController popToViewController:controller animated:YES];
        }
    }}

@end
