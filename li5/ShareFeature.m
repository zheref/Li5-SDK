//
//  ShareFeature.m
//  li5
//
//  Created by Martin Cocaro on 1/31/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

@import FBSDKCoreKit;
@import FBSDKShareKit;
@import Intercom;
@import Li5Api;

#import "PreviewRecordingUIViewController.h"
#import <Heap/Heap.h>
#import "ShareFeature.h"

@interface ShareFeature () <FBSDKSharingDelegate>

@property (nonatomic, copy) void (^onShareFinished)(NSError *error, BOOL cancelled);

@property (nonatomic, strong) FBSDKShareLinkContent *_content;
@property (nonatomic, weak) UIViewController *_baseViewController;

@end

@implementation ShareFeature

@synthesize product = _product;

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    __content = [[FBSDKShareLinkContent alloc] init];
}

- (void)setProduct:(Product *)product {
    _product = product;
    
    [self syncFBData];
}

- (void)syncFBData {
    DDLogVerbose(@"");
    __content.contentTitle = self.product.shareMessage;
    __content.contentDescription = self.product.title;
    __content.hashtag = [FBSDKHashtag hashtagWithString:self.product.shareMessage];
    __content.ref = [[NSURL URLWithString:self.product.shareUrl] lastPathComponent];
    __content.contentURL = [NSURL URLWithString:self.product.shareUrl];
}

- (void)present:(UIViewController*)parentVC completion:(void (^)(NSError *, BOOL))completion {
    DDLogVerbose(@"");
    __baseViewController = parentVC;
    _onShareFinished = completion;
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = __baseViewController;
    dialog.shareContent = self._content;
    dialog.mode = FBSDKShareDialogModeShareSheet;
    
    [dialog setDelegate:self];
    
    [dialog show];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [FBSDKAppEvents logEvent:@"ShareProduct"];
    
    [[Li5ApiHandler sharedInstance] postShareForProductWithID:self.product.id withCompletion:^(NSError *error) {
        if (error) {
            DDLogError(@"Error - %@",error.description);
            [[CrashlyticsLogger sharedInstance] logError:error userInfo:nil];
        } else {
            if (self.product.isEligibleForMultiLevel) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success",nil)
                                                                message:NSLocalizedString(@"Now when a friend of yours signs up and buys this product, you will get it for FREE!",nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"😻 Great!",nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            NSDictionary *params = @{@"product":self.product.id};
            NSString *eventName =@"Ended Sharing successfull";
            [Intercom logEventWithName:eventName metaData:params];
            [Heap track:eventName withProperties:params];
        }
        
        if (_onShareFinished) {
            _onShareFinished(error,YES);
        }
    }];
    
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    DDLogVerbose(@"");
    if (_onShareFinished) {
        _onShareFinished(nil,NO);
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    DDLogVerbose(@"");
    NSArray *objectsToShare = @[self.product.title, self.product.shareMessage, self.product.shareUrl];
    
    ActivityViewController *activityVC = [[ActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[ UIActivityTypePostToWeibo,
                                    UIActivityTypePrint,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToTencentWeibo,
                                    UIActivityTypeAirDrop,
                                    UIActivityTypeOpenInIBooks
                                    ];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [activityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if(completed){
            [self sharer:nil didCompleteWithResults:nil];
        } else {
            [self sharerDidCancel:nil];
        }
    }];
    
    [__baseViewController presentViewController:activityVC animated:YES completion:nil];
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
