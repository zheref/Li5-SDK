//
//  UserProfileViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import Li5Api;
@import SDWebImage;
@import AVFoundation;

//#import "UserProfileDismissDynamicInteractor.h"
#import "UserProfileViewController.h"
#import "Li5RootFlowController.h"
#import "AppDelegate.h"
#import "Li5VolumeView.h"
#import "Li5-Swift.h"

@interface UserProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *lovesButton;
@property (weak, nonatomic) IBOutlet UIButton *ordersButton;

@property (weak, nonatomic) IBOutlet UIView *productsBgView;
@property (weak, nonatomic) IBOutlet UIView *userLovesView;
@property (weak, nonatomic) IBOutlet UIView *userOrdersView;

@property (weak, nonatomic) UIViewController * viewController;

@end

@implementation UserProfileViewController

+ (id)initWithPanTarget:(id<UserProfileViewControllerPanTargetDelegate>)panTarget andViewController:(UIViewController *)viewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    UserProfileViewController *newSelf = [storyboard instantiateInitialViewController];
    if (newSelf)
    {
        newSelf.panTarget = panTarget;
        newSelf.viewController = viewController;
    }
    
    return newSelf;
}

- (void)awakeFromNib
{
    //Do needed
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];//action:@selector(userDidPan:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [self.lovesButton setBackgroundImage:[UIImage imageWithColor:[UIColor li5_redColor] andRect:self.lovesButton.bounds] forState:UIControlStateSelected];
    [self.ordersButton setBackgroundImage:[UIImage imageWithColor:[UIColor li5_redColor] andRect:self.ordersButton.bounds] forState:UIControlStateSelected];
    
    [self.productsBgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bGPatternImage"]]];
    
    self.ordersButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.lovesButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
    
    [self userDidTapLovesButton:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self refreshProfile];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.userImage.layer.cornerRadius = self.userImage.bounds.size.width / 2;
    self.userImage.clipsToBounds = YES;
}

- (void)refreshProfile
{
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    Profile *userProfile = [flowController userProfile];
    if (userProfile)
    {
        [self.userNameLabel setText:[NSString stringWithFormat:@"%@ %@",userProfile.first_name,userProfile.last_name]];
        [self.userImage sd_setImageWithURL:[NSURL URLWithString:userProfile.picture]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"lovesEmbed"]) {
        //_childViewController = (UserProductsViewController *) [segue destinationViewController];
    }
    else if ([segueName isEqualToString: @"ordersEmbed"]) {
        
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"showSettings"])
    {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - Gesture Recognizers

- (IBAction)userDidTapLovesButton:(id)sender
{
    [self.lovesButton setSelected:TRUE];
    self.lovesButton.layer.borderWidth = 0;
    
    [self.ordersButton setSelected:FALSE];
    self.ordersButton.layer.borderWidth = 0.5;
    
    [self.userLovesView setHidden:FALSE];
    [self.userOrdersView setHidden:TRUE];
}

- (IBAction)userDidTapOrdersButton:(id)sender
{
    [self.ordersButton setSelected:TRUE];
    [self.lovesButton setSelected:FALSE];
    
    self.lovesButton.layer.borderWidth = 0.5;
    self.ordersButton.layer.borderWidth = 0;
    
    [self.userLovesView setHidden:TRUE];
    [self.userOrdersView setHidden:FALSE];
}

- (void)userDidPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self.panTarget userDidPan:gestureRecognizer];
}

#pragma mark - User Actions

- (IBAction)settingsButtonTouched:(id)sender
{
}

@end
