//
//  UserSettingsViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/22/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import BCVideoPlayer;
@import SDWebImage;
@import TSMessages;

#import "AppDelegate.h"
#import "UserSettingsViewController.h"
#import "RootViewController.h"
#import "Li5Constants.h"

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
                    @"Action" : @"nop"
                    },
                @{
                    @"Name" : @"Terms & Privacy Policy",
                    @"Action" : @"nop"
                    },
                @{
                    @"Name" : @"Support",
                    @"Action" : @"nop"
                    }
                ],
        @"Shipping and Billing" : @[
                @{
                    @"Name" : @"Shipping Information",
                    @"Action" : @"nop"
                    },
                @{
                    @"Name" : @"Credit Cards",
                    @"Action" : @"nop"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
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

    cell.title.text = [[_settings valueForKey:_settings.allKeys[indexPath.section]][indexPath.row] valueForKey:@"Name"];

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
    if ([cell.textLabel.text isEqualToString:@"Logout"])
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

- (void)userLogOut
{
    Li5ApiHandler *handler = [Li5ApiHandler sharedInstance];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    if ([handler clearAccessToken])
    {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.parentViewController dismissViewControllerAnimated:NO completion:^{
                UINavigationController *navVC = (UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
                DDLogDebug(@"viewControllers: %@",navVC.viewControllers);
                [navVC popToRootViewControllerAnimated:NO];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"LogoutSuccessful" object:nil];
            }];
        });
    }
}

- (void)shareLogs
{
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

- (void)clearUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kLi5SwipeLeftExplainerViewPresented];
    [defaults removeObjectForKey:kLi5SwipeDownExplainerViewPresented];
    
    [TSMessage setDefaultViewController:self];
    [TSMessage showNotificationWithTitle:@"Success"
                                subtitle:@"Standard Defaults cleared."
                                    type:TSMessageNotificationTypeSuccess];
}

- (void)clearCache
{
    [BCPlayer clearCache];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    
    [TSMessage setDefaultViewController:self];
    [TSMessage showNotificationWithTitle:@"Success"
                                subtitle:@"Cache cleared ok."
                                    type:TSMessageNotificationTypeSuccess];
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