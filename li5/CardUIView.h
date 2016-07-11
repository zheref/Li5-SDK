//
//  CardUIView.h
//  li5
//
//  Created by Martin Cocaro on 6/20/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5View.h"

@protocol CardUIViewDelegate <NSObject>

- (void)cardDismissed;

@end

//IB_DESIGNABLE
@interface CardUIView : Li5View

@property (nonatomic, weak) IBOutlet id<CardUIViewDelegate> delegate;

@end
