//
//  ImageCardViewController.m
//  li5
//
//  Created by Martin Cocaro on 6/17/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import Li5Api;
@import SDWebImage;

#import "ImageCardViewController.h"
#import "CardUICollectionViewCell.h"

@interface ImageCardViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ImageCardViewController

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    
}

- (void)setProduct:(Product *)product
{
    _product = product;
    
    [self.collectionView reloadData];
}

#pragma mark - UI Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.product.images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CardUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cardView" forIndexPath:indexPath];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.product.images[indexPath.row].url]
                           placeholderImage:nil
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                      //DDLogVerbose(@"completed");
                                  }];
    
    return cell;
}

@end
