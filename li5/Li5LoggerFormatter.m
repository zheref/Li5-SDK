//
//  Li5LoggerFormatter.m
//  li5
//
//  Created by Martin Cocaro on 4/26/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
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
    int len;
    char ts[24] = "";
    size_t tsLen = 0;

    if (logMessage->_timestamp)
    {
        NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:_calendarUnitFlags fromDate:logMessage->_timestamp];

        NSTimeInterval epoch = [logMessage->_timestamp timeIntervalSinceReferenceDate];
        int milliseconds = (int)((epoch - floor(epoch)) * 1000);

        len = snprintf(ts, 24, "%04ld-%02ld-%02ld %02ld:%02ld:%02ld:%03d", // yyyy-MM-dd HH:mm:ss:SSS
                       (long)components.year,
                       (long)components.month,
                       (long)components.day,
                       (long)components.hour,
                       (long)components.minute,
                       (long)components.second, milliseconds);

        tsLen = (NSUInteger)MAX(MIN(24 - 1, len), 0);
    }

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
