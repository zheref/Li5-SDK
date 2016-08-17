//
//  ImageUICollectionViewCell.h
//  li5
//
//  Created by Martin Cocaro on 6/6/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

@import MMMaterialDesignSpinner;

@interface ImageUICollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;

@end
