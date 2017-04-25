//
//  ShareFeature.h
//  li5
//
//  Created by Martin Cocaro on 1/31/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareFeature : NSObject

@property (nonatomic,weak) Product *product;

- (void)present:(UIViewController*)parentVC completion:(void(^)(NSError *error, BOOL cancelled))completion;

@end

@interface UIActivityViewController (Private)

- (BOOL)_shouldExcludeActivityType:(UIActivity*)activity;

@end

@interface ActivityViewController : UIActivityViewController

@end
