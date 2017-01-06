//
//  UserSettingsViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/22/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import BCVideoPlayer;
@import SDWebImage;
@import TSMessages;
@import Intercom;
@import DigitsKit;

#import "AppDelegate.h"
#import "UserSettingsViewController.h"
#import "Li5RootFlowController.h"
#import "Li5Constants.h"
#import "Li5VolumeView.h"
#import "PaymentInfoViewController.h"

@interface UserSettingsViewController ()

@property (nonatomic, strong) NSDictionary<NSString *, NSArray<NSDictionary<NSString *, NSString *> *> *> *settings;

@end

@implementation UserSettingsViewController

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _settings = @{
                  @"About" : @[
                          @{
                              @"Name" : @"Rate our App",
                              @"Action" : @"rateApp"
                              },
                          @{
                              @"Name" : @"Terms & Privacy Policy",
                              @"Action" : @"loadTos"
                              },
                          @{
                              @"Name" : @"Support",
                              @"Action" : @"presentMessenger"
                              }
                          ],
                  @"Shipping and Billing" : @[
                          @{
                              @"Name" : @"Shipping Information",
                              @"Action" : @"shippingInfo"
                              },
                          @{
                              @"Name" : @"Credit Cards",
                              @"Action" : @"creditCardInfo"
                              }
                          ],
                  @"User" : @[
                          @{
                              @"Name" : @"Logout",
                              @"Action" : @"userLogOut"
                              }
                          ]
#if DEBUG
                  ,
                  @"Development" : @[
                          @{
                              @"Name" : @"Reset to Demo",
                              @"Action" : @"enterDemoMode"
                              },
                          @{
                              @"Name" : @"Reset User Defaults",
                              @"Action" : @"clearUserDefaults"
                              },
                          @{
                              @"Name" : @"Clear Cache",
                              @"Action" : @"clearCache"
                              },
                          @{
                              @"Name" : @"Logs",
                              @"Action" : @"shareLogs"
                              }
                          ]
#endif
                  };
}

#pragma mark - UI Setup

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [@"Settings" uppercaseString];
    self.navigationController.navigationBar.topItem.title = @"";
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = [@"Settings" uppercaseString];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor li5_redColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"back"]];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                      NSFontAttributeName: [UIFont fontWithName:@"Rubik-Medium" size:18.0]
                                                                      }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _settings.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_settings valueForKey:_settings.allKeys[section]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCellView"];
    
    cell.title.text = [[[_settings valueForKey:_settings.allKeys[indexPath.section]][indexPath.row] valueForKey:@"Name"] uppercaseString];
    
    NSString *toggleString = [[_settings valueForKey:_settings.allKeys[indexPath.section]][indexPath.row] valueForKey:@"Toggle"];
    
    if (toggleString)
    {
        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchview setAccessibilityLabel:toggleString];
        [switchview addTarget:self action:@selector(toggleString:) forControlEvents:UIControlEventTouchUpInside];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [switchview setOn:[userDefaults boolForKey:toggleString]];
        cell.accessoryView = switchview;
    }
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _settings.allKeys[section].uppercaseString;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == _settings.allKeys.count - 1)
    {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        NSString *version = infoDictionary[@"CFBundleShortVersionString"];
        NSString *build = infoDictionary[(NSString *)kCFBundleVersionKey];
        NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
        return [NSString stringWithFormat:@"%@ - v%@(%@)", bundleName, version, build];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView*)view;
    [headerView.textLabel setFont:[UIFont fontWithName:@"Rubik-Bold" size:14.0]];
    [headerView.textLabel setTextColor:[UIColor grayColor]];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
    footerView.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell.textLabel.text compare:@"Logout" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [cell.textLabel setFont:[UIFont fontWithName:@"Rubik-Medium" size:18.0]];
        [cell.textLabel setTextColor:[UIColor li5_redColor]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *action = [[_settings valueForKey:_settings.allKeys[indexPath.section]][indexPath.row] valueForKey:@"Action"];
    [self performSelector:NSSelectorFromString(action) withObject:nil afterDelay:0.0];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - User Actions

- (void)nop
{
}

- (void)presentMessenger {
    DDLogDebug(@"%p",self);
    [Intercom presentMessenger];
    
}

- (void)userLogOut
{
    DDLogDebug(@"%p",self);
    Li5ApiHandler *handler = [Li5ApiHandler sharedInstance];
    [handler revokeRefreshAccessTokenWithCompletion:^void (NSError *error){
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [[Digits sharedInstance] logOut];
        // This resets the Intercom for iOS cache of your users’ identities
        // and wipes the slate clean.
        [Intercom reset];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:kLogoutSuccessful object:nil];
        });
    }];
}

- (void)shareLogs
{
    DDLogDebug(@"%p",self);
    DDFileLogger *logger = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).logger;
    NSArray *sortedLogFileInfos = [logger.logFileManager sortedLogFileInfos];
    NSMutableArray *objectsToShare = [NSMutableArray array];
    
    for (int i = 0; i < MIN(sortedLogFileInfos.count, logger.logFileManager.maximumNumberOfLogFiles); i++)
    {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
        NSData *fileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
        [objectsToShare addObjectsFromArray:@[ fileData ]];
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[
                                   UIActivityTypePostToWeibo,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToTencentWeibo,
                                   UIActivityTypePostToTwitter,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeMessage,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypePostToFacebook,
                                   ];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)enterDemoMode
{
    DDLogDebug(@"%p",self);
    [self clearUserDefaults];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"Li5DiscoverModeCustom"];
    [self userLogOut];
}

- (void)clearUserDefaults
{
    DDLogDebug(@"%p",self);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kLi5SwipeLeftExplainerViewPresented];
    [defaults removeObjectForKey:kLi5SwipeDownExplainerViewPresented];
    [defaults removeObjectForKey:kLi5SwipeUpExplainerViewPresented];
    [defaults removeObjectForKey:kLi5CategoriesSelectionViewPresented];
    [defaults removeObjectForKey:kLi5ShareExplainerViewPresented];
    [defaults removeObjectForKey:@"Li5DiscoverModeCustom"];

    [TSMessage showNotificationInViewController:self
                                          title:@"Success"
                                       subtitle:@"Standard Defaults cleared."
                                           type:TSMessageNotificationTypeSuccess
                                       duration:0.5];
    
    [self userLogOut];
}

- (void)clearCache
{
    DDLogDebug(@"%p",self);
    [BCPlayer clearCache];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    
    [TSMessage showNotificationInViewController:self
                                          title:@"Success"
                                       subtitle:@"Cache cleared ok."
                                           type:TSMessageNotificationTypeSuccess
                                       duration:0.5];
}

- (void)toggleString:(UISwitch *)aSwitch
{
    DDLogDebug(@"%p",self);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[aSwitch isOn] forKey:aSwitch.accessibilityLabel];
    [self userLogOut];
}

- (void)shippingInfo {
    DDLogDebug(@"%p",self);
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    Profile *userProfile = [flowController userProfile];
    
    if (userProfile)
    {
        UIViewController *vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"profileShippingInfoVC"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)creditCardInfo {
    DDLogDebug(@"%p",self);
    Li5RootFlowController *flowController = (Li5RootFlowController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] flowController];
    Profile *userProfile = [flowController userProfile];
    
    if (userProfile)
    {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentInfoSelectVC"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)loadTos {
    DDLogDebug(@"%p",self);
    UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"tosVC"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)rateApp {
    DDLogDebug(@"%p",self);
    NSString *appId = [[NSBundle mainBundle].infoDictionary objectForKey:@"Li5AppId"];
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appId]];
    
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation SettingViewCell

@end
