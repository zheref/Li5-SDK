//
//  ProductPageActionsView.m
//  li5
//
//  Created by Martin Cocaro on 6/5/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import Li5Api;
@import AudioToolbox;

#import "ProductPageActionsView.h"
#import "Li5-Swift.h"

@interface ProductPageActionsView ()

@property (weak, nonatomic) IBOutlet HeartAnimationView *loveButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UILabel *loveCounter;
@property (weak, nonatomic) IBOutlet UILabel *reviewsCounter;

@end

@implementation ProductPageActionsView

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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    [super initialize];
    
    [self.loveButton setDelegate:self];
}

#pragma mark - Public Methods

- (void)setProduct:(Product *)product
{
    _product = product;
    
    [self.loveButton setSelected:_product.isLoved];
    self.loveCounter.text = [_product.loves stringValue];
}

#pragma mark - User Actions

- (IBAction)shareProduct:(UIButton*)button
{
    DDLogVerbose(@"Share Button Pressed");
    NSURL *productURL = [NSURL URLWithString:[[[[Li5ApiHandler sharedInstance] baseURL] stringByAppendingPathComponent:@"p"] stringByAppendingPathComponent:self.product.id]];
    
    NSArray *objectsToShare = @[ self.product.title, productURL ];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[ UIActivityTypePostToWeibo,
                                    UIActivityTypePrint,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToTencentWeibo,
                                    UIActivityTypeAirDrop ];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [[self parentViewController] presentViewController:activityVC animated:YES completion:nil];
}

- (void)didTapButton
{
    DDLogVerbose(@"Love Button Pressed");
    if (self.loveButton.selected)
    {
        self.product.isLoved = false;
        [self.loveButton setSelected:false];
        self.loveCounter.text = [@([self.loveCounter.text integerValue] - 1) stringValue];
        
        [[Li5ApiHandler sharedInstance] deleteLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
            if (error != nil)
            {
                self.product.isLoved = true;
                [self.loveButton setSelected:true];
                self.loveCounter.text = [@([self.loveCounter.text integerValue] + 1) stringValue];
            }
        }];
    }
    else
    {
        self.product.isLoved = true;
        [self.loveButton setSelected:true];
        self.loveCounter.text = [@([self.loveCounter.text integerValue] + 1) stringValue];
        
        //Vibrate sound
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        [[Li5ApiHandler sharedInstance] postLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
            if (error != nil)
            {
                self.product.isLoved = false;
                [self.loveButton setSelected:false];
                self.loveCounter.text = [@([self.loveCounter.text integerValue] - 1) stringValue];
            }
        }];
    }
}

@end
