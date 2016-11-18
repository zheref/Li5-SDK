//
//  ProductPageActionsView.m
//  li5
//
//  Created by Martin Cocaro on 6/5/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//
@import Li5Api;
@import AudioToolbox;
@import Branch;

#import "ProductPageActionsView.h"
#import "Li5-Swift.h"

@interface ProductPageActionsView ()
{
    NSTimer *__t;
    BOOL _isEligibleForMultiLevel;
}

@property (weak, nonatomic) IBOutlet HeartAnimationView *loveButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UILabel *loveCounter;
@property (weak, nonatomic) IBOutlet UILabel *reviewsCounter;

@property (weak, nonatomic) IBOutlet UIView *multilevelCallout;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UILabel *multilevelLabel;

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
}

#pragma mark - Public Methods

- (void)setProduct:(Product *)product isEligibleForMultiLevel:(BOOL)isEligibleForMultiLevel
{
    _isEligibleForMultiLevel = isEligibleForMultiLevel;
    _product = product;
    
    [self refreshStatus];
}

- (void)refreshStatus
{
    DDLogVerbose(@"");
    [self.loveButton setSelected:_product.isLoved];
    self.loveCounter.text = [_product.loves stringValue];
    
    self.multilevelCallout.hidden = !self.product.isEligibleForMultiLevel;
    
    if(self.product.isEligibleForMultiLevel) {
        
        if(!_isEligibleForMultiLevel){
            self.multilevelCallout.frame = self.shareButton.frame;
            self.multilevelLabel.alpha = 0.0;
        }
    }
    
    // Initialize a Branch Universal Object for the page the user is viewing
    self.branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:self.product.id];
    // Define the content that the object represents
    self.branchUniversalObject.title = self.product.title;
    self.branchUniversalObject.contentDescription = @"Check out this awesome piece of content";
    self.branchUniversalObject.canonicalUrl = self.product.shareUrl;
    [self.branchUniversalObject addMetadataKey:@"share_token" value:[[NSURL URLWithString:self.product.shareUrl] lastPathComponent]];
    // Trigger a view on the content for analytics tracking
    [self.branchUniversalObject registerView];
    // List on Apple Spotlight
    [self.branchUniversalObject listOnSpotlight];
}

- (void)animate
{
    DDLogVerbose(@"%p",self);
    if (_isEligibleForMultiLevel) {
    
        
         __t  = [NSTimer scheduledTimerWithTimeInterval:3.5
                                         target:self
                                       selector:@selector(dissmisAnimation)
                                       userInfo:nil
                                        repeats:NO];
    
//        __t = [NSTimer scheduledTimerWithTimeInterval:3.5
//                               repeats:NO
//                                 block:^(NSTimer * _Nonnull timer) {
//                                     dispatch_async(dispatch_get_main_queue(), ^{
//                                         [UIView transitionWithView:self.multilevelCallout
//                                                           duration:.75
//                                                            options:UIViewAnimationOptionTransitionCrossDissolve
//                                                         animations:^{
//                                                             self.multilevelCallout.frame = self.shareButton.frame;
//                                                             self.multilevelLabel.alpha = 0.0;
//                                                         }
//                                                         completion:nil];
//                                     });
//                                 }];
    }
}

-(void)dissmisAnimation {

    [UIView transitionWithView:self.multilevelCallout
                      duration:.75
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.multilevelCallout.frame = self.shareButton.frame;
                        self.multilevelLabel.alpha = 0.0;
                    }
                    completion:nil];
}
#pragma mark - User Actions

- (IBAction)shareProduct:(UIButton*)button
{
    DDLogVerbose(@"Share Button Pressed");
//    NSArray *objectsToShare = @[self.product.title, self.product.shareUrl];
//
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
//    [[self parentViewController] presentViewController:activityVC animated:YES completion:^{
//        [[Li5ApiHandler sharedInstance] postShareForProductWithID:self.product.id withCompletion:^(NSError *error) {
//            if (error) {
//                DDLogError(@"Error - %@",error.description);
//            }
//        }];
//    }];
    
    // More link properties available at https://dev.branch.io/getting-started/configuring-links/guide/#link-control-parameters
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.feature = @"sharing";
    [linkProperties addControlParam:@"$desktop_url" withValue:self.product.shareUrl];
    // Show the share sheet for the content you want the user to share. A link will be automatically created and put in the message.
    [self.branchUniversalObject showShareSheetWithLinkProperties:linkProperties
                                                    andShareText:@"Hey friend - I know you'll love this: "
                                              fromViewController:[self parentViewController]
                                                      completion:^(NSString *activityType, BOOL completed) {
                                                          if (completed) {
                                                              // This code path is executed if a successful share occurs
                                                              [[Li5ApiHandler sharedInstance] postShareForProductWithID:self.product.id withCompletion:^(NSError *error) {
                                                                  if (error) {
                                                                      DDLogError(@"Error - %@",error.description);
                                                                  }
                                                              }];
                                                          }
                                                      }];
}

- (void)didTapButton
{
    DDLogVerbose(@"Love Button Pressed");
    if (self.loveButton.selected)
    {
        self.product.isLoved = false;
        [self.loveButton setSelected:false];
        self.product.loves = @([self.product.loves integerValue] - 1);
        self.loveCounter.text = [self.product.loves stringValue];
        
        [[Li5ApiHandler sharedInstance] deleteLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
            if (error != nil)
            {
                self.product.isLoved = true;
                [self.loveButton setSelected:true];
                self.product.loves = @([self.product.loves integerValue] + 1);
                self.loveCounter.text = [self.product.loves stringValue];
            }
        }];
    }
    else
    {
        self.product.isLoved = true;
        [self.loveButton setSelected:true];
        self.product.loves = @([self.product.loves integerValue] + 1);
        self.loveCounter.text = [self.product.loves stringValue];
        
        //Vibrate sound
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        [[Li5ApiHandler sharedInstance] postLoveForProductWithID:self.product.id withCompletion:^(NSError *error) {
            if (error != nil)
            {
                self.product.isLoved = false;
                [self.loveButton setSelected:false];
                self.product.loves = @([self.product.loves integerValue] - 1);
                self.loveCounter.text = [self.product.loves stringValue];
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
