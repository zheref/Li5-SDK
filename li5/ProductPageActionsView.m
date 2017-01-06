//
//  ProductPageActionsView.m
//  li5
//
//  Created by Martin Cocaro on 6/5/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import Li5Api;
@import AudioToolbox;
@import Branch;
@import Intercom;
@import JSBadgeView;
@import FBSDKCoreKit;
@import FBSDKShareKit;

#import "ProductPageActionsView.h"
#import "Li5-Swift.h"
#import "Heap.h"
#import "Li5Constants.h"
#import "CardUIView.h"
#import "ShareExplainerUIViewController.h"

@interface ProductPageActionsView () <FBSDKSharingDelegate,CardUIViewDelegate>
{
    NSTimer *__t;
    BOOL _animate;
}

@property (weak, nonatomic) IBOutlet HeartAnimationView *loveButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UILabel *loveCounter;
@property (weak, nonatomic) IBOutlet UILabel *reviewsCounter;
@property (strong, nonatomic) JSBadgeView *badgeView;

@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *unlockedMultilevelCallout;

@property (nonatomic,weak) Product *product;

@property BranchUniversalObject *branchUniversalObject;

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
    
    self.badgeView = [[JSBadgeView alloc] initWithParentView:self.commentsButton alignment:JSBadgeViewAlignmentTopRight];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUnreadCount:)
                                                 name:IntercomUnreadConversationCountDidChangeNotification
                                               object:nil];
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
    
    if(self.product.isEligibleForMultiLevel) {
        if(!_animate){
            self.unlockedMultilevelCallout.hidden = NO;
        }
    }
    
    [self updateUnreadCount:nil];
}

- (void)updateUnreadCount:(NSNotification*)notification {
    NSUInteger unreadCount = [Intercom unreadConversationCount];
    if (unreadCount) {
        self.badgeView.badgeText = [[NSNumber numberWithUnsignedInteger:unreadCount] stringValue];
    } else {
        self.badgeView.hidden = YES;
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
    
    [Intercom updateUserWithAttributes:@{
                                         @"custom_attributes": @{
                                         @"last_product_view": self.product.title
                                                 }
                                         }];
    [Intercom presentMessenger];
    
}

- (void)cardDismissed
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:TRUE forKey:kLi5ShareExplainerViewPresented];
    
    [[self parentViewController] beginAppearanceTransition:YES animated:NO];
    [[self parentViewController] endAppearanceTransition];
    
    [self shareProduct:self.shareButton];
}

- (BOOL)presentShareExplainerViewIfNeeded
{
    DDLogVerbose(@"");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kLi5ShareExplainerViewPresented])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProductPageViews" bundle:[NSBundle mainBundle]];
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
    
    if (![self presentShareExplainerViewIfNeeded]) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentTitle = self.product.shareMessage;
        content.contentDescription = self.product.title;
        content.hashtag = [FBSDKHashtag hashtagWithString:self.product.shareMessage];
        content.ref = [[NSURL URLWithString:self.product.shareUrl] lastPathComponent];
        content.contentURL = [NSURL URLWithString:self.product.shareUrl];
        
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.fromViewController = [self parentViewController];
        dialog.shareContent = content;
        dialog.mode = FBSDKShareDialogModeShareSheet;
        
        [dialog setDelegate:self];
        
        [dialog show];
        
        //    NSArray *objectsToShare = @[self.product.title, self.product.shareUrl];
        //    ActivityViewController *activityVC = [[ActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        //
        //    NSArray *excludeActivities = @[ UIActivityTypePostToWeibo,
        //                                    UIActivityTypePrint,
        //                                    UIActivityTypeAssignToContact,
        //                                    UIActivityTypeSaveToCameraRoll,
        //                                    UIActivityTypeAddToReadingList,
        //                                    UIActivityTypePostToFlickr,
        //                                    UIActivityTypePostToTencentWeibo,
        //                                    UIActivityTypeAirDrop,
        //                                    UIActivityTypeOpenInIBooks
        //                                  ];
        //
        //    activityVC.excludedActivityTypes = excludeActivities;
        //
        //    [activityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        //        if(completed){
        //            [FBSDKAppEvents logEvent:@"ShareProduct"];
        //
        //            [[Li5ApiHandler sharedInstance] postShareForProductWithID:self.product.id withCompletion:^(NSError *error) {
        //                if (error) {
        //                    DDLogError(@"Error - %@",error.description);
        //                } else {
        //                    if (self.product.isEligibleForMultiLevel) {
        //                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
        //                                                                        message:@"Now when a friend of yours signs up and buys through your link, you will get the same product for FREE!"
        //                                                                       delegate:self
        //                                                              cancelButtonTitle:@"😻 Great!"
        //                                                              otherButtonTitles:nil];
        //                        [alert show];
        //                    }
        //                }
        //            }];
        //        }
        //    }];
        //    
        //    [[self parentViewController] presentViewController:activityVC animated:YES completion:nil];
        //
    }
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [FBSDKAppEvents logEvent:@"ShareProduct"];

    [[Li5ApiHandler sharedInstance] postShareForProductWithID:self.product.id withCompletion:^(NSError *error) {
        if (error) {
            DDLogError(@"Error - %@",error.description);
        } else {
            if (self.product.isEligibleForMultiLevel) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"Now when a friend of yours signs up and buys this product, you will get it for FREE!"
                                                               delegate:self
                                                      cancelButtonTitle:@"😻 Great!"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }];

}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
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
        
        [FBSDKAppEvents logEvent:@"LoveProduct"];
        [Heap track:@"Li5.LoveProduct" withProperties:@{}];
        
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

@implementation ActivityViewController

- (BOOL)_shouldExcludeActivityType:(UIActivity *)activity
{
    if ([[activity activityType] isEqualToString:@"com.apple.reminders.RemindersEditorExtension"] ||
        [[activity activityType] isEqualToString:@"com.apple.mobilenotes.SharingExtension"]) {
        return YES;
    }
    return [super _shouldExcludeActivityType:activity];
}

@end
