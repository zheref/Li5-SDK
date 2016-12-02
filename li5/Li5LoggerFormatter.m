//
//  Li5LoggerFormatter.m
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "Li5LoggerFormatter.h"

@interface Li5LoggerFormatter ()
{
    NSUInteger _calendarUnitFlags;
    int _atomicLoggerCount;
    NSDateFormatter *_threadUnsafeDateFormatter;
    NSString *_appName;
}

@end

@implementation Li5LoggerFormatter

#pragma mark - class lifecycle

- (id)init
{
    self = [super init];

    if (self)
    {
        _appName = [[NSProcessInfo processInfo] processName];
        _calendarUnitFlags = (NSCalendarUnitYear |
                              NSCalendarUnitMonth |
                              NSCalendarUnitDay |
                              NSCalendarUnitHour |
                              NSCalendarUnitMinute |
                              NSCalendarUnitSecond);
    }

    return self;
}

#pragma mark - protocol DDLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    char ts[24] = "";

    NSString *dateAndTime = [NSString stringWithCString:ts encoding:NSUTF8StringEncoding];
    NSString *logMsg = logMessage->_message;

    return [NSString stringWithFormat:@"%@ %@[p:%d/t:%@] %@[l:%lu] %@",
                                      dateAndTime,
                                      _appName,
                                      (int)getpid(),
                                      [logMessage threadID],
                                      logMessage.function,
                                      (unsigned long)logMessage->_line,
                                      logMsg];
}

@end
