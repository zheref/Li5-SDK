//
//  DetailsViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/20/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import Li5Api;
@import SDWebImage;

#import "DetailsDescriptionViewController.h"
#import "DetailsViewController.h"
#import "ImageCardViewController.h"
#import "ImageUICollectionViewCell.h"
#import "Li5Constants.h"
#import "Li5VolumeView.h"
#import "UILabel+Li5.h"

@interface DetailsViewController () {
    BOOL __hasAppeared;
}

@property (assign, nonatomic) ProductContext pContext;

@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *productVendorLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyNowBtn;
@property (weak, nonatomic) IBOutlet UILabel *originalPrice;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollection;
@property (weak, nonatomic) IBOutlet UILabel *offerDisclaimer;

@property (nonatomic, weak) Order *order;

@end

@implementation DetailsViewController

@synthesize product, previousViewController, nextViewController;

#pragma mark - Init

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
    __hasAppeared = NO;
}

+ (id)detailsWithProduct:(Product *)thisProduct andContext:(ProductContext)ctx
{
    UIStoryboard *productPageStoryboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle bundleForClass:[self class]]];
    DetailsViewController *newSelf = [productPageStoryboard instantiateViewControllerWithIdentifier:@"DetailsView"];
    if (newSelf)
    {
        newSelf.product = thisProduct;
        newSelf.pContext = ctx;
    }
    return newSelf;
}

+ (id)detailsWithOrder:(Order*)thisOrder andContext:(ProductContext)ctx
{
    UIStoryboard *productPageStoryboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle bundleForClass:[self class]]];
    DetailsViewController *newSelf = [productPageStoryboard instantiateViewControllerWithIdentifier:@"DetailsView"];
    if (newSelf)
    {
        newSelf.order = thisOrder;
        newSelf.product = thisOrder.product;
        newSelf.pContext = ctx;
    }
    return newSelf;
}

#pragma mark - UI Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.product.hasOffer)
    {
        [self.originalPrice setHidden:TRUE];
    }
    else
    {
        self.offerDisclaimer.hidden = NO;
        
        NSString *orPriceWord = NSLocalizedString(@"O.PRICE: ",nil);
        NSString *orPrice = [NSString stringWithFormat:@"$%.00f",[self.product.originalPrice doubleValue] / 100];
        NSString *originalPrice = [NSString stringWithFormat:@"%@ %@",orPriceWord, orPrice];
        NSMutableAttributedString *originalPriceText = [[NSMutableAttributedString alloc] initWithString:originalPrice
                                                                                              attributes:@{
                                                                                                           NSFontAttributeName : [UIFont fontWithName:@"Rubik" size:16.0],
                                                                                                           NSForegroundColorAttributeName : [UIColor blackColor]
                                                                                                           }];
        
        NSRange orPriceWordRange = [originalPrice rangeOfString:orPriceWord];
        NSRange orPriceRange = [originalPrice rangeOfString:orPrice];
        [originalPriceText addAttribute:NSStrikethroughStyleAttributeName value:@2.0 range:orPriceRange];
        [originalPriceText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Rubik" size:13.0] range:orPriceWordRange];
        
        self.originalPrice.attributedText = originalPriceText;
    }
    
    self.productTitleLabel.text = self.product.title;
    self.productVendorLabel.text = [self.product.brand uppercaseString];
    
    if (self.product.body != nil && self.product.body.length > 0)
    {
        NSString *cleanBody = [self.product.body stringByReplacingOccurrencesOfString:@"[\\t\\n\\r]+"
                                                                           withString:@" "
                                                                              options:NSRegularExpressionSearch
                                                                                range:NSMakeRange(0, self.product.body.length)];
        
        NSString *readMoreText = NSLocalizedString(@" READ MORE",nil);
        NSString *productDescription = [cleanBody stringByAppendingString:readMoreText];
        
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
        
    }
    
    NSString *price = [NSString stringWithFormat:@"$%.00f",[self.product.price doubleValue] / 100];
    NSString *buttonCTA = [NSString stringWithFormat:NSLocalizedString(@"BUY NOW AT %@",nil), price];
    if ([self.product.stock isEqualToNumber:@(0)]) {
        buttonCTA = NSLocalizedString(@"SOLD OUT",nil);
        self.buyNowBtn.enabled = NO;
    }
    if (self.order != nil)
    {
        buttonCTA = NSLocalizedString(@"See Details",nil);
    }
    
    NSMutableAttributedString *buyNowText = [[NSMutableAttributedString alloc] initWithString:buttonCTA
                                                                                   attributes:@{
                                                                                                NSFontAttributeName : [UIFont fontWithName:@"Rubik-Bold" size:20.0],
                                                                                                NSForegroundColorAttributeName : [UIColor li5_whiteColor]
                                                                                                }];
    
    [self.buyNowBtn setAttributedTitle:buyNowText forState:UIControlStateNormal];
    [self.buyNowBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] andRect:self.buyNowBtn.bounds] forState:UIControlStateDisabled];
    
    self.imagesCollection.hidden = (self.product.images.count == 0);
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self presentExplainerViewsIfNeeded];
    
    __hasAppeared = YES;
    [self.imagesCollection reloadData];
}

- (void)presentExplainerViewsIfNeeded
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kLi5SwipeUpExplainerViewPresented] && self.pContext == kProductContextDiscover)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle bundleForClass:[self class]]];
        UIViewController *explainerView = [storyboard instantiateViewControllerWithIdentifier:@"SwipeUpExplainerView"];
        
        [self presentViewController:explainerView animated:NO completion:^{
            
        }];
    }
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
    if (!self.product.images || !self.product.images.count || !__hasAppeared)
        return 0;
    return self.product.images.count < 3 ?: 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageUICollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageView" forIndexPath:indexPath];
    
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [imageCell.imageView sd_setImageWithURL:[NSURL URLWithString:self.product.images[indexPath.row].url]
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

- (IBAction)buyAction:(UIButton *)btn
{    
   
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
