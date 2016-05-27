//
//  UserSettingsViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/22/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "AppDelegate.h"
#import "UserSettingsViewController.h"
#import "RootViewController.h"

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
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
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
    return _settings.allKeys[section];
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

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
    footerView.textLabel.textAlignment = NSTextAlignmentCenter;
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

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation SettingViewCell

@end