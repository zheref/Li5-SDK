//
//  ProductPageViewController.m
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5Constants.h"
#import "ProductPageViewController.h"
#import "VideoViewController.h"

@interface ProductPageViewController ()

@end

@implementation ProductPageViewController

@synthesize product;

- (id)initWithProduct:(Product *)thisProduct forContext:(ProductContext)context
{
    DDLogVerbose(@"%@", thisProduct.title);
    self = [super initWithDirection:Li5UIPageViewControllerDirectionVertical];
    if (self)
    {
        self.product = thisProduct;
        self.viewControllers = @[ [[VideoViewController alloc] initWithProduct:self.product andContext:context], [DetailsViewController detailsWithProduct:self.product andContext:context] ];
    }
    return self;
}

- (id)initWithOrder:(Order *)order forContext:(ProductContext)context
{
    DDLogVerbose(@"%@", order.product.title);
    self = [super initWithDirection:Li5UIPageViewControllerDirectionVertical];
    if (self)
    {
        self.product = order.product;
        self.viewControllers = @[ [[VideoViewController alloc] initWithProduct:self.product andContext:context], [DetailsViewController detailsWithOrder:order andContext:context] ];
    }
    return self;
}

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setPriority:(BCPriority)priority
{
    [((VideoViewController*)self.viewControllers.firstObject) setPriority:priority];
}

-(BCPlayer *)getPlayer{
    return [(VideoViewController *)self.currentViewController getPlayer];
}

#pragma mark - OS Actions


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.currentViewController.view.frame = self.view.bounds;
}

- (void)dealloc
{
    DDLogDebug(@"%p",self);
}

- (void)didReceiveMemoryWarning
{
    DDLogDebug(@"");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
