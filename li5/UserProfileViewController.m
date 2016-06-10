//
//  UserProfileViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import Li5Api;
@import SDWebImage;

#import "UserProfileViewController.h"

@interface UserProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *lovesButton;
@property (weak, nonatomic) IBOutlet UIButton *ordersButton;

@property (nonatomic, strong) Profile *userProfile;

@property (weak, nonatomic) IBOutlet UIView *productsBgView;
@property (weak, nonatomic) IBOutlet UIView *userLovesView;
@property (weak, nonatomic) IBOutlet UIView *userOrdersView;

@end

@implementation UserProfileViewController

- (id)initWithPanTarget:(id<UserProfileViewControllerPanTargetDelegate>)panTarget
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    self = [storyboard instantiateInitialViewController];
    if (self)
    {
        _panTarget = panTarget;
    }
    return self;
}

- (void)awakeFromNib
{
    //Do needed
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.userImage.layer.cornerRadius = self.userImage.bounds.size.width / 2;
    self.userImage.layer.masksToBounds = YES;
    
    [self.lovesButton setBackgroundImage:[UIImage imageWithColor:[UIColor li5_redColor] andRect:self.lovesButton.bounds] forState:UIControlStateSelected];
    [self.ordersButton setBackgroundImage:[UIImage imageWithColor:[UIColor li5_redColor] andRect:self.ordersButton.bounds] forState:UIControlStateSelected];
    
    [self.productsBgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bGPatternImage"]]];
    
    self.ordersButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.lovesButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self userDidTapLovesButton:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    __weak typeof(self) welf = self;
    Li5ApiHandler *handler = [Li5ApiHandler sharedInstance];
    [handler requestProfile:^(NSError *error, Profile *profile) {
        __strong typeof(welf) sself = welf;
        if (!error)
        {
            sself.userProfile = profile;
            [sself.userNameLabel setText:[NSString stringWithFormat:@"%@ %@",sself.userProfile.first_name,sself.userProfile.last_name]];
            [sself.userImage sd_setImageWithURL:[NSURL URLWithString:sself.userProfile.picture]];
        }
    }];
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
    CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
    double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
    if(fabs(degree) > 20.0)
    {
        [self.panTarget userDidPan:gestureRecognizer];
    }
}

#pragma mark - User Actions

- (IBAction)settingsButtonTouched:(id)sender
{
}

@end
