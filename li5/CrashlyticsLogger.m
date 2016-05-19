//
//  CrashlyticsLogger.m
//  li5
//
//  Created by Martin Cocaro on 5/16/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "CrashlyticsLogger.h"

@import Crashlytics;

OBJC_EXTERN void CLSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

@implementation CrashlyticsLogger

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = logMessage->_message;

    if (_logFormatter)
    {
        logMsg = [_logFormatter formatLogMessage:logMessage];
    }

    if (logMsg)
    {
        CLSLog(@"%@", logMsg);
    }
}
+ (CrashlyticsLogger *)sharedInstance
{
    static dispatch_once_t pred = 0;
    static CrashlyticsLogger *_sharedInstance = nil;

    dispatch_once(&pred, ^{
      _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}
@end