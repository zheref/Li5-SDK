//
//  UserProfileViewController.m
//  li5
//
//  Created by Martin Cocaro on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import "UserProfileViewController.h"

@interface UserProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logsButton;

@property (nonatomic, strong) Profile *userProfile;

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
    
    Li5ApiHandler *handler = [Li5ApiHandler sharedInstance];
    [handler requestProfile:^(NSError *error, Profile *profile) {
      if (!error)
      {
          _userProfile = profile;
          [_userNameLabel setText:_userProfile.email];
      }
    }];
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"products_embed"]) {
        //_childViewController = (UserProductsViewController *) [segue destinationViewController];
    }
}

#pragma mark - Gesture Recognizers

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
