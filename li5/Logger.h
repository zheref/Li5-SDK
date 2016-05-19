//
//  Logger.h
//  li5
//
//  Created by Martin Cocaro on 1/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#ifndef Logger_h
#define Logger_h

#define LOG_LEVEL_DEF ddLogLevel
@import CocoaLumberjack;
#import "CrashlyticsLogger.h"

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelError;
#endif


#endif /* Logger_h */
