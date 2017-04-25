//
//  UpdateAvailableFeature.m
//  li5
//
//  Created by Martin Cocaro on 2/1/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

#import "UpdateAvailableFeature.h"

@interface UpdateAvailableFeature () {
    NSOperationQueue *__flowQueue;
}

@property (nonatomic, weak) UIViewController *rootViewController;

@end

@implementation UpdateAvailableFeature

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    if (self) {
        _rootViewController = rootViewController;
        
        [self initialize];
    }
    return self;
}

- (void)initialize {
    __flowQueue = [NSOperationQueue new];
    [__flowQueue setName:@"Flow Queue"];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(cancelCheckUpdate:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(checkUpdateAvailable:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];

}

- (void)cancelCheckUpdate:(NSNotification *)notif {
    [__flowQueue cancelAllOperations];
}

- (void)checkUpdateAvailable:(NSNotification *)notif {
    [__flowQueue addOperationWithBlock:^{
        NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString* appID = infoDictionary[@"CFBundleIdentifier"];
        NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?bundleId=%@",appID];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSURLResponse *response;
        NSError *error;
        NSData *jsonData = [NSURLConnection  sendSynchronousRequest:request returningResponse:&response error: &error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSError *jsonError = nil;
        
        ItunesAppStoreLookup *lookup = [[ItunesAppStoreLookup alloc] initWithString:jsonString error:&jsonError];

        if (!jsonError && lookup.result && lookup.result.count > 0) {
            NSString *localAppVersion = infoDictionary[@"CFBundleShortVersionString"];
            
            if ([((ItunesAppStoreResult*)lookup.result.firstObject).version compare:localAppVersion options:NSNumericSearch] == NSOrderedDescending) {
                // currentVersion is lower than the version
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Version",nil)
                                                                               message:NSLocalizedString(@"A better newer version is available for download. Check it out!",nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings",nil) style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           
                                                                           NSString *appId = [[NSBundle mainBundle].infoDictionary objectForKey:@"Li5AppId"];
                                                                           NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appId]];
                                                                           
                                                                           [[UIApplication sharedApplication] openURL:url];
                                                                           
                                                                       }];
                
                [alert addAction:settingsAction];
                [alert addAction:defaultAction];
                [self.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation ItunesAppStoreResult

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"version": @"version",
                                                       }];
}

@end


@implementation ItunesAppStoreLookup

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"results": @"result",
                                                       }];
}

@end
