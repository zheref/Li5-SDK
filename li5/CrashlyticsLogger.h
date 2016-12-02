//
//  CrashlyticsLogger.h
//  li5
//
//  Created by Martin Cocaro on 5/16/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#ifndef CrashlyticsLogger_h
#define CrashlyticsLogger_h

#import "DDLog.h"

@interface CrashlyticsLogger : DDAbstractLogger

+(CrashlyticsLogger*) sharedInstance;

@end

#endif /* CrashlyticsLogger_h */
