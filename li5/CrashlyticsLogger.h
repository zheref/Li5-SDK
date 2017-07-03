//
//  CrashlyticsLogger.h
//  li5
//
//  Created by Martin Cocaro on 5/16/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#ifndef CrashlyticsLogger_h
#define CrashlyticsLogger_h

@interface CrashlyticsLogger : DDAbstractLogger

+(CrashlyticsLogger*) sharedInstance;

- (void)logError:(NSError*)err userInfo:(id)userObj;

@end

#endif /* CrashlyticsLogger_h */
