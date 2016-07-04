//
//  ImageCardViewController.h
//  li5
//
//  Created by Martin Cocaro on 6/17/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;

#import <UIKit/UIKit.h>

@interface ImageCardViewController : UIViewController <UICollectionViewDataSource>

@property (nonatomic, weak) Product *product;

@end
