//
//  ImageHelper.m
//  li5
//
//  Created by gustavo hansen on 7/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ImageHelper.h"

@interface ImageHelper()

@property (strong, nonatomic) NSURLSessionTask *task;

@end

@implementation ImageHelper

- (void)getImage:(NSURL * _Nonnull)url
completationHandler:(void (^ _Nonnull)(NSData * _Nullable))completationHandler {
    
    NSString *basePath = [[NSString alloc] initWithFormat:@"%@/cache",
                          NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]];
    
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@", basePath, url.lastPathComponent];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:filePath]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completationHandler(data);
        });
    }
    else {
        
        self.task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if(data != nil){
                [data writeToFile:filePath atomically:true];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completationHandler(data);
            });
        }];
        
        [self.task resume];
    }
}

-(void)cancel {
    
    if(self.task != nil) {
        if(self.task.state == NSURLSessionTaskStateRunning){
            [self.task cancel];
        }
    }
}

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    
    [self cancel];
    
    self.task = nil;
}

@end