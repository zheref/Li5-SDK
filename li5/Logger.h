//
//  Logger.h
//  li5
//
//  Created by Martin Cocaro on 1/19/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#ifndef Logger_h
#define Logger_h

#undef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF ddLogLevel

#define GWS_LOG_DEBUG(...) DDLogDebug(__VA_ARGS__)
#define GWS_LOG_VERBOSE(...) DDLogVerbose(__VA_ARGS__)
#define GWS_LOG_INFO(...) DDLogInfo(__VA_ARGS__)
#define GWS_LOG_WARNING(...) DDLogWarn(__VA_ARGS__)
#define GWS_LOG_ERROR(...) DDLogError(__VA_ARGS__)
#define GWS_LOG_EXCEPTION(__EXCEPTION__) DDLogError(@"%@", __EXCEPTION__)

@import CocoaLumberjack;
#import "CrashlyticsLogger.h"

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelError;
#endif


#endif /* Logger_h */
