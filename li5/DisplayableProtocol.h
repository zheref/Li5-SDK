//
//  DisplayableProtocol.h
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@protocol DisplayableProtocol <NSObject>

- (void)hideAndMoveToViewController:(UIViewController *)viewController;
- (void)show;
- (void)redisplay;

@end
