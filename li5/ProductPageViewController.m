//
//  ProductPageViewController.m
//  li5
//
//  Created by Martin Cocaro on 2/11/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "Li5Constants.h"
#import "Li5SDK/ProductPageViewController.h"

#import "VideoViewController.h"
#import <Li5SDK/Li5SDK-Swift.h>

@interface ProductPageViewController()

@end

@implementation ProductPageViewController

@synthesize product;


- (id)initWithProduct:(Product *)thisProduct forContext:(ProductContext)context
{
    NSLog(@"ProductPageViewController >>> %@", thisProduct.title);
    
    self = [super initWithDirection:Li5UIPageViewControllerDirectionVertical];
    
    if (self)
    {
        self.product = thisProduct;
        BOOL noMore = self.product.isAd ||
                            ([self.product.type caseInsensitiveCompare:@"url"] == NSOrderedSame &&
                                self.product.contentUrl == nil);
        
        if (noMore) {
            self.viewControllers = @[ [[VideoViewController alloc] initWithProduct:self.product andContext:context]];
        } else {
            self.viewControllers = @[[[VideoViewController alloc] initWithProduct:self.product andContext:context],
                                     
                                        ([self.product.type caseInsensitiveCompare:@"url"] == NSOrderedSame ?
                                         [[DetailsHTMLViewController alloc] initWithProduct:self.product andContext:context]
                                       : [DetailsViewController detailsWithProduct:self.product andContext:context])
                                     ];
            
        }
    }
    
    return self;
}


- (void)viewDidLoad
{
    NSLog(@"ProductPageVC did load");
    [self.view setBackgroundColor: [UIColor yellowColor]];
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"ProductPageVC did appear");
    [super viewDidAppear:animated];
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
