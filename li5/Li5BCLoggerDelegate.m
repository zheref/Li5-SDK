//
//  Li5BCLoggerDelegate.m
//  li5
//
//  Created by Martin Cocaro on 6/16/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5BCLoggerDelegate.h"

@implementation Li5BCLoggerDelegate

- (void)logError:(NSString *)message params:(NSArray *)params
{
    DDLogError(@"%@ - %@", message, params);
}

- (void)logVerbose:(NSString *)message
{
    //DDLogVerbose(@"%@", message);
}

- (void)logVerbose:(NSString *)message params:(NSArray *)params
{
    //DDLogVerbose(@"%@ - %@", message, params);
}

@end
