//
//  PaymentInfoSelectViewController.m
//  li5
//
//  Created by gustavo hansen on 10/17/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

@import VMaskTextField;
@import MBProgressHUD;

#import "PaymentInfoSelectViewController.h"
#import "Li5RootFlowController.h"
#import "AppDelegate.h"
#import "PaymentInfoViewController.h"
#import "Li5ApiHandler.h"

@interface PaymentInfoSelectViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIButton *selectPayment;

@property (weak, nonatomic) IBOutlet VMaskTextField *creditCardNumber;
@property (weak, nonatomic) IBOutlet VMaskTextField *ccExpiration;
@property (weak, nonatomic) IBOutlet VMaskTextField *ccCvv;

@property (weak, nonatomic) IBOutlet UITextField *creditCardName;
@property (weak, nonatomic) UITextField *activeTextField;
@property (weak, nonatomic) IBOutlet UITextField *alias;

@property NSArray<Card *> *cards;

@property Card * currentCard;

@end

@implementation PaymentInfoSelectViewController

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    
    self.title = [@"Payments" uppercaseString];
    self.navigationController.navigationBar.topItem.title = @"";
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    
    Profile *userProfile = [flowController userProfile];
    
    if(userProfile.defaultCard != nil) {
        
        self.creditCardNumber.enabled = false;
        self.ccExpiration.enabled = false;
        self.creditCardName.enabled = false;
        self.ccCvv.enabled = false;
        self.alias.enabled = false;
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
        self.navigationItem.rightBarButtonItem = edit;
        
        [self defaultCard];
    }
    
    self.emptyView.hidden = userProfile.defaultCard != nil;
}


-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.title = [@"Payments" uppercaseString];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    
    Profile *userProfile = [flowController userProfile];
    
    if(userProfile.defaultCard != nil) {
        
        self.creditCardNumber.enabled = false;
        self.ccExpiration.enabled = false;
        self.creditCardName.enabled = false;
        self.ccCvv.enabled = false;
        self.alias.enabled = false;
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
        self.navigationItem.rightBarButtonItem = edit;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.emptyView.hidden = userProfile.defaultCard != nil;
    
    [[Li5ApiHandler sharedInstance] requestUserCreditCardsWithCompletion:^(NSError *error, NSArray<Card *> *cards) {
        
        [hud hideAnimated:YES];
        
        if (error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            
            self.emptyView.hidden = cards.count != 0;
            
            if(cards.count != 0) {
                
                if(self.cards.count < cards.count){
                    
                    [self handlePaymentChange:cards.lastObject];
                    self.cards = cards;
                    
                    return;
                }
                else if(self.currentCard != nil) {
                    
                    self.cards = cards;
                    for (Card *card in self.cards) {
                        
                        if(card.id == self.currentCard.id) {
                            
                            [self handlePaymentChange:card];
                            return;
                        }
                    }
                }
            }
            
            self.cards = cards;
            [self defaultCard];
            
        }
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)defaultCard {
    
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    
    Profile *userProfile = [flowController userProfile];
    
    if (userProfile.defaultCard)
    {
        [self handlePaymentChange:userProfile.defaultCard];
    }
}

- (void)edit {
    
    PaymentInfoViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
    
    [paymentVC setCurrentCard:self.currentCard];
    
    [self.navigationController pushViewController:paymentVC animated:YES];
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
        
        if(_currentCard.id == card.id){
            
            [action setValue:[UIImage imageNamed:@"check.png"] forKey:@"_image"];
        }
        
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

- (void)handlePaymentChange:(Card *)card {
    
    self.currentCard = card;
    self.creditCardName.text = card.name;
    self.alias.text = card.alias ;
    self.creditCardNumber.text = [NSString stringWithFormat: @"**** **** **** %@", card.last4];
    self.ccCvv.text = @"****";
    self.ccExpiration.text = [NSString stringWithFormat: @"%@/%@",
                              card.expirationMonth,  [[card.expirationYear stringValue] substringFromIndex:2]];
    
    [self.selectPayment setTitle:card.alias.length > 0 ? card.alias :
     self.creditCardNumber.text forState:UIControlStateNormal];
    
}

@end
