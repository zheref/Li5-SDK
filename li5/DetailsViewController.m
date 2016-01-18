//
//  DetailsViewController.m
//  li5
//
//  Created by Martin Cocaro on 1/20/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

@synthesize product, imagesViewController, images, imagePageControl;

- (id) initWithProduct:(Product *) thisProduct
{
    self = [super init];
    if (self) {
        //DDLogVerbose(@"Initializing DetailsViewController for: %@", thisProduct.title);
        self.product = thisProduct;
        self.imagesViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        self.imagesViewController.dataSource = self;
        self.imagesViewController.delegate = self;
        [self addChildViewController:imagesViewController];
        self.images = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //DDLogVerbose(@"Loading DetailsViewController for: %@", self.product.title);
    
    //Set white background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //Scroll View
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height-70)];
    scrollView.delegate = self;
    scrollView.delaysContentTouches = NO;
    
    //Vendor Name Label
    UIFont *vendorFont = [UIFont fontWithName:@"Avenir" size:14];
    CGRect vendorSize = [product.vendor boundingRectWithSize:CGSizeMake(scrollView.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:vendorFont} context:nil];
    UILabel *vendorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,[self currentBottomIn:scrollView].size.height+10,scrollView.frame.size.width-120,vendorSize.size.height)];
    [vendorLabel setTextColor:[UIColor blueColor]];
    [vendorLabel setNumberOfLines:0];
    [vendorLabel setFont:vendorFont];
    [vendorLabel setText: product.vendor];
    [vendorLabel setTextAlignment: NSTextAlignmentLeft];
    [scrollView addSubview:vendorLabel];
    
    //Ratings section
    CGRect ratingFrame = CGRectMake(scrollView.frame.size.width-100,vendorLabel.frame.origin.y,80,vendorLabel.frame.size.height);
    UIBezierPath* trianglePath = [ShapesHelper stars:5 shapeInFrame:ratingFrame];
    CAShapeLayer *ratingLayer = [CAShapeLayer layer];
    [ratingLayer setFrame:ratingFrame];
    [ratingLayer setPath:trianglePath.CGPath];
    [ratingLayer setFillColor:[[UIColor yellowColor] CGColor]];
    [scrollView.layer addSublayer:ratingLayer];
    
    //Product Title Label
    UIFont *productTitleFont = [UIFont fontWithName:@"Avenir-Black" size:18];
    CGRect productTitleSize = [product.title boundingRectWithSize:CGSizeMake(scrollView.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:productTitleFont} context:nil];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,[self currentBottomIn:scrollView].size.height+5,self.view.frame.size.width-20,productTitleSize.size.height)];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setNumberOfLines:0];
    [titleLabel setFont:productTitleFont];
    [titleLabel setText: product.title];
    [titleLabel setTextAlignment: NSTextAlignmentLeft];
    [scrollView addSubview:titleLabel];
    
    //Add product image resized
    CGRect imageFrame = CGRectMake(0,0,self.view.frame.size.width, 375);
    CGRect swipeFrame = CGRectMake(0, [self currentBottomIn:scrollView].size.height+10, self.view.frame.size.width, 375);
    
    [imagesViewController.view setFrame:swipeFrame];
    
    //Request image data from the URL:
    for (int i = 0; i<self.product.images.count; i++) {
        NSString *image = self.product.images[i];
        IndexedViewController *imageViewController = [[IndexedViewController alloc] init];
        imageViewController.index = i;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [imageViewController.view addSubview:imageView];

        [self.images addObject:imageViewController];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:image]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imgData)
                {
                    //Load the data into an UIImage:
                    UIImage *backgroundImage = [UIImage imageWithData:imgData];
                    //Check if your image loaded successfully:
                    if (backgroundImage)
                    {
                        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, 0);
                        [backgroundImage drawInRect:imageFrame];
                        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        imageView.image = resizedImage;
                        [self.view bringSubviewToFront:imagePageControl];
                    }
                }
            });
        });
        
    }
    
    [imagesViewController setViewControllers:@[self.images[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    [scrollView addSubview:imagesViewController.view];
    
    imagePageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,[self currentBottomIn:scrollView].size.height - 37, self.view.frame.size.width, 37)];
    imagePageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    imagePageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    imagePageControl.backgroundColor = [UIColor clearColor];
    imagePageControl.currentPage = 0;
    imagePageControl.numberOfPages = self.product.images.count;
    [scrollView addSubview:imagePageControl];
    
    //Product Price Label
    NSString *price = @"Price: ";
    UIFont *productPriceFont = [UIFont fontWithName:@"Avenir-Black" size:16];
    CGRect productPriceSize = [product.price boundingRectWithSize:CGSizeMake(self.view.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:productPriceFont} context:nil];
    UILabel *productPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,[self currentBottomIn:scrollView].size.height+10,self.view.frame.size.width-20,productPriceSize.size.height)];
    [productPriceLabel setTextColor:[UIColor blackColor]];
    [productPriceLabel setNumberOfLines:0];
    [productPriceLabel setFont:productPriceFont];
    NSMutableAttributedString *attributedProductPrice = [[NSMutableAttributedString alloc] initWithString:price attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:14], NSForegroundColorAttributeName: [UIColor grayColor]}];
    [attributedProductPrice appendAttributedString:[[NSMutableAttributedString alloc] initWithString:product.price attributes:@{NSFontAttributeName:productPriceFont, NSForegroundColorAttributeName: [UIColor blackColor]}]];
    [productPriceLabel setAttributedText: attributedProductPrice];
    [productPriceLabel setTextAlignment: NSTextAlignmentLeft];
    [scrollView addSubview:productPriceLabel];
    
    //Add Product Description
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(20,[self currentBottomIn:scrollView].size.height+10, self.view.frame.size.width-40, self.view.frame.size.height))];
    [descriptionLabel setTextColor:[UIColor blackColor]];
    [descriptionLabel setFont:[UIFont fontWithName:@"Avenir" size:16]];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [descriptionLabel setTextAlignment: NSTextAlignmentLeft];
    descriptionLabel.text = product.desc;
    descriptionLabel.contentScaleFactor = [UIScreen mainScreen].scale;
    [descriptionLabel sizeToFit];
    [scrollView addSubview:descriptionLabel];
    
    //Update scrollview content size based on subviews
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [self currentBottomIn:scrollView].size.height);
    
    //Add ScrollView to View
    [self.view addSubview:scrollView];
    
    //Add Buy button
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [firstButton setTitle:product.cta forState:UIControlStateNormal];
    [firstButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    firstButton.frame = CGRectMake(12.5,self.view.bounds.size.height-60, self.view.bounds.size.width-25, 50);
    firstButton.backgroundColor = [UIColor yellowColor];
    firstButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:18];
    firstButton.layer.cornerRadius = 5;
    firstButton.clipsToBounds = YES;
    firstButton.layer.contentsGravity = kCAGravityBottom;
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyAction:)];
    [firstButton addGestureRecognizer:tapGesture];
    
    [self.view addSubview:firstButton];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if ( imagesViewController == pageViewController)
    {
        imagePageControl.currentPage = [(IndexedViewController*)[imagesViewController.viewControllers firstObject] index];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ( pageViewController == self.imagesViewController )
    {
        NSUInteger index = ((IndexedViewController*) viewController).index;
        
        if ((index == 0) || (index == NSNotFound))
        {
            return nil;
        }
        return self.images[index-1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ( pageViewController == self.imagesViewController )
    {
        NSUInteger index = ((IndexedViewController*) viewController).index;
        
        if ((index+1 == [self.images count]) || (index == NSNotFound))
        {
            return nil;
        }
        return self.images[index+1];
    }
    return nil;
}
 
-(CGRect) currentBottomIn: (UIView*) currentView
{
    CGRect contentRect = CGRectZero;
    for (UIView *view in currentView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    return contentRect;
}

-(void)viewDidLayoutSubviews {
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) buyAction: (UITapGestureRecognizer *)gestureRecognizer {
    //DDLogVerbose(@"Buy Button tapped");
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //DDLogVerbose(@"Did end decelerating");
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //DDLogVerbose(@"Did scroll");
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate{
    //DDLogVerbose(@"Did end dragging");
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    //DDLogVerbose(@"Did begin decelerating");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //DDLogVerbose(@"Did begin dragging");
}

- (void) hide
{
    //Do nothing
}

- (void) show
{
    //Do nothing
}

- (void) redisplay
{
    //Do nothing
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
