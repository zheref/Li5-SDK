//
//  DetailsViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/20/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import Li5Api;
@import SDWebImage;

#import "DetailsViewController.h"
#import "ImageUICollectionViewCell.h"
#import "UILabel+Li5.h"
#import "ImageCardViewController.h"
#import "Li5VolumeView.h"
#import "DetailsDescriptionViewController.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *productVendorLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyNowBtn;

@property (nonatomic, weak) Order *order;

@end

@implementation DetailsViewController

@synthesize product, previousViewController, nextViewController;

#pragma mark - Init

+ (id)detailsWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx
{
    UIStoryboard *productPageStoryboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle mainBundle]];
    DetailsViewController *newSelf = [productPageStoryboard instantiateViewControllerWithIdentifier:@"DetailsView"];
    if (newSelf)
    {
        newSelf.product = thisProduct;
    }
    return newSelf;
}

+ (id)detailsWithOrder:(Order*)thisOrder andContext:(ProductContext)ctx
{
    UIStoryboard *productPageStoryboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle mainBundle]];
    DetailsViewController *newSelf = [productPageStoryboard instantiateViewControllerWithIdentifier:@"DetailsView"];
    if (newSelf)
    {
        newSelf.order = thisOrder;
        newSelf.product = thisOrder.product;
    }
    return newSelf;
}

#pragma mark - UI Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DDLogVerbose(@"%@", self.product.title);
    
    self.productTitleLabel.text = self.product.title;
    self.productVendorLabel.text = [self.product.brand uppercaseString];

    NSString *readMoreText = @" READ MORE";
    NSString *productDescription = [self.product.body stringByAppendingString:readMoreText];

    NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc] initWithString:productDescription
                                                                                 attributes:@{
                                                                                     NSFontAttributeName : [UIFont fontWithName:@"Rubik" size:18.0],
                                                                                     NSForegroundColorAttributeName : [UIColor blackColor]
                                                                                 }];

    NSRange readMoreRange = [productDescription rangeOfString:readMoreText];
    [bodyText addAttribute:NSForegroundColorAttributeName value:[UIColor li5_cyanColor] range:readMoreRange];
    [bodyText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Rubik-Medium" size:16.0] range:readMoreRange];

    [self.productDescriptionLabel setAttributedText:bodyText];
    [self.productDescriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.productDescriptionLabel setContentScaleFactor:[[UIScreen mainScreen] scale]];

    NSString *price = [NSString stringWithFormat:@"$%.00f",[self.product.price doubleValue] / 100];
    NSString *buttonCTA = [NSString stringWithFormat:@"BUY NOW %@", price];
    if (self.order != nil)
    {
        buttonCTA = self.order.status;
        [self.buyNowBtn setEnabled:NO];
    }

    NSMutableAttributedString *buyNowText = [[NSMutableAttributedString alloc] initWithString:buttonCTA
                                                                                   attributes:@{
                                                                                       NSFontAttributeName : [UIFont fontWithName:@"Rubik-Bold" size:20.0],
                                                                                       NSForegroundColorAttributeName : [UIColor li5_whiteColor]
                                                                                   }];

    [self.buyNowBtn setAttributedTitle:buyNowText forState:UIControlStateNormal];
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
}

- (IBAction)myUnwindAction:(UIStoryboardSegue*)unwindSegue
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"presentDescription"])
    {
        DetailsDescriptionViewController *dvc = (DetailsDescriptionViewController *) [segue destinationViewController];
        [dvc setProduct:self.product];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!self.product.images || !self.product.images.count)
        return 0;
    return self.product.images.count < 3 ?: 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageUICollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageView" forIndexPath:indexPath];

    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [imageCell.imageView sd_setImageWithURL:[NSURL URLWithString:self.product.images[indexPath.row]]
                           placeholderImage:nil
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                      //DDLogVerbose(@"completed");
                                  }];

    return imageCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCardViewController *cardsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageCardsView"];
    [cardsVC setProduct:self.product];
    [self presentViewController:cardsVC animated:NO completion:nil];
}

#pragma mark - User Actions

- (IBAction)buyAction:(UITapGestureRecognizer *)gestureRecognizer
{
    //DDLogVerbose(@"Buy Button tapped");
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
