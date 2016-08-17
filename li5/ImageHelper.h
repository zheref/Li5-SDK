//
//  ImageHelper.h
//  li5
//
//  Created by gustavo hansen on 7/19/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import AVFoundation;

@interface ImageHelper : NSObject

- (void)getImage:(NSURL * _Nonnull)url
completationHandler:(void (^ _Nonnull)(NSData * _Nullable))completationHandler;

-(void)cancel;

@end