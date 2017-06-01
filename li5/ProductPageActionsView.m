//
//  ProductPageActionsView.m
//  li5
//
//  Created by Martin Cocaro on 6/5/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import Li5Api;
@import AudioToolbox;

#import "ProductPageActionsView.h"
#import <Li5SDK/Li5SDK-Swift.h>
#import "Li5Constants.h"
#import "CardUIView.h"
#import "ShareExplainerUIViewController.h"
#import "Li5UINavigationController.h"

@interface ProductPageActionsView () <CardUIViewDelegate>
{
    NSTimer *__t;
    BOOL _animate;
}

@property (weak, nonatomic) IBOutlet HeartAnimationView *loveButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UILabel *loveCounter;
@property (weak, nonatomic) IBOutlet UILabel *reviewsCounter;

@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *unlockedMultilevelCallout;

@property (nonatomic,weak) Product *product;

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
    
#ifdef EMBED
    self.loveButton.hidden = YES;
    self.commentsButton.hidden = YES;
    self.shareButton.hidden = YES;
#endif
}

#pragma mark - Public Methods

- (void)setProduct:(Product *)product animate:(BOOL)animate
{
    _product = product;
    _animate = animate;
    
    [self refreshStatus];
}

- (void)refreshStatus
{
    DDLogVerbose(@"");
    [self.loveButton setSelected:_product.isLoved];
    self.loveCounter.text = [self friendlyNumber:_product.loves.longLongValue];
    
    self.unlockedMultilevelCallout.hidden = !self.product.isEligibleForMultiLevel;
    if (self.product.isEligibleForMultiLevel) {
        [self.shareButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    if(self.product.isEligibleForMultiLevel) {
        if(!_animate){
            self.unlockedMultilevelCallout.hidden = NO;
        }
    }
}

- (void)animate
{
    DDLogVerbose(@"%p",self);
}

-(void)dissmisAnimation {
    DDLogVerbose(@"%p",self);
}

#pragma mark - User Actions

- (IBAction)chatButton:(id)sender {
    
    [[self parentViewController] beginAppearanceTransition:NO animated:NO];
    [[self parentViewController] endAppearanceTransition];
}

- (void)cardDismissed
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:TRUE forKey:kLi5ShareExplainerViewPresented];
    
    [self shareProduct:self.shareButton];
}

- (BOOL)presentShareExplainerViewIfNeeded
{
    DDLogVerbose(@"");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kLi5ShareExplainerViewPresented])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle bundleForClass:[self class]]];
        ShareExplainerUIViewController *explainerView = (ShareExplainerUIViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ShareExplainerView"];
        explainerView.delegate = self;
        
        [[self parentViewController] presentViewController:explainerView animated:NO completion:^{
            [[self parentViewController] beginAppearanceTransition:NO animated:NO];
            [[self parentViewController] endAppearanceTransition];
        }];
        
        return YES;
    }
    return NO;
}

- (IBAction)shareProduct:(UIButton*)button
{
    DDLogVerbose(@"Share Button Pressed");
    
    NSDictionary *params = @{@"product":self.product.id};
    
    if (![self presentShareExplainerViewIfNeeded]) {
        
#if FULL_VERSION
        [self presentRecordShareUIView];
#else
        [self presentShareView];
#endif
    }
}

- (void)presentShareView {
    
    [[self parentViewController] beginAppearanceTransition:NO animated:NO];
    [[self parentViewController] endAppearanceTransition];
    
    __weak typeof(self) welf = self;
}

- (BOOL)presentRecordShareUIView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle bundleForClass:[self class]]];
    
    return TRUE;
}

-(NSString *)friendlyNumber:(long long)num{
    
    NSString *stringNumber;
    
    if (num < 1000) {
        stringNumber = [NSString stringWithFormat:@"%lld", num];
        
    }else if(num < 1000000){
        float newNumber = floor(num / 100) / 10.0;
        stringNumber = [NSString stringWithFormat:@"%.1fK", newNumber];
        
    }else{
        float newNumber = floor(num / 100000) / 10.0;
        stringNumber = [NSString stringWithFormat:@"%.1fM", newNumber];
    }
    return stringNumber;
}

- (void)didTapButton
{
    DDLogVerbose(@"Love Button Pressed");
    if (self.loveButton.selected)
    {
        self.product.isLoved = false;
        [self.loveButton setSelected:false];
        self.product.loves = @([self.product.loves integerValue] - 1);
        self.loveCounter.text = [self friendlyNumber:self.product.loves.longLongValue];
        
        NSDictionary *params = @{@"product":self.product.id};
        
        [[Li5ApiHandler sharedInstance] deleteLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
            if (error != nil)
            {
                self.product.isLoved = true;
                [self.loveButton setSelected:true];
                self.product.loves = @([self.product.loves integerValue] + 1);
                self.loveCounter.text = [self friendlyNumber:self.product.loves.longLongValue];
            }
        }];
    }
    else
    {
        self.product.isLoved = true;
        [self.loveButton setSelected:true];
        self.product.loves = @([self.product.loves integerValue] + 1);
        self.loveCounter.text = [self friendlyNumber:self.product.loves.longLongValue];
        
        //Vibrate sound
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        NSDictionary *params = @{@"product":self.product.id};
        
        [[Li5ApiHandler sharedInstance] postLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
            if (error != nil)
            {
                self.product.isLoved = false;
                [self.loveButton setSelected:false];
                self.product.loves = @([self.product.loves integerValue] - 1);
                self.loveCounter.text = [self friendlyNumber:self.product.loves.longLongValue];
            }
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (void)dealloc
{
    [__t invalidate];
    __t = nil;
}

@end
