//
//  Li5SearchBarUIView.h
//  li5
//
//  Created by Martin Cocaro on 6/9/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5View.h"

@protocol Li5SearchBarUIViewDelegate;

//IB_DESIGNABLE
@interface Li5SearchBarUIView : Li5View <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) UIViewController<Li5SearchBarUIViewDelegate> *delegate;

- (void)setText:(NSString*)text;

- (NSString*)text;

@end


@protocol Li5SearchBarUIViewDelegate <NSObject>

@optional

- (BOOL)shouldBeginEditing:(Li5SearchBarUIView *)searchBar;
- (void)searchBar:(Li5SearchBarUIView *)searchBar textDidChange:(NSString *)searchText;
- (void)searchButtonClicked:(Li5SearchBarUIView *)searchBar;
- (void)cancelButtonClicked:(Li5SearchBarUIView *)searchBar;

@end