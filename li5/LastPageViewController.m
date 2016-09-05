//
//  LastPageViewController.m
//  li5
//
//  Created by Leandro Fournier on 4/27/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "ExploreDynamicInteractor.h"
#import "LastPageViewController.h"
#import "Li5Constants.h"
#import "Li5VolumeView.h"
#import "SwipeDownToExploreViewController.h"
#import "UserProfileDynamicInteractor.h"

@interface LastPageViewController ()
{
    UIPanGestureRecognizer *profilePanGestureRecognizer;
    UIPanGestureRecognizer *searchPanGestureRecognizer;
    id<UserProfileViewControllerPanTargetDelegate> profileInteractor;
    id<ExploreViewControllerPanTargetDelegate> searchInteractor;
    
    id __playerEndObserver;
    BOOL __hasAppeared;
}

@property (weak, nonatomic) IBOutlet UIView *staticView;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (nonatomic, strong) BCPlayer *player;
@property (nonatomic, strong) BCPlayerLayer *playerLayer;
@property (nonatomic, strong) AVAudioPlayer* audioPlayer;

@end

@implementation LastPageViewController

@synthesize product;

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
    
}

#pragma mark - Public Methods

- (void)setLastVideoURL:(NSString *)lastVideoURL
{
    _lastVideoURL = lastVideoURL;
    
    _player = [[BCPlayer alloc] initWithUrl:[NSURL URLWithString:self.lastVideoURL] bufferInSeconds:50.0 priority:BCPriorityPlay delegate:self];
    _playerLayer = [[BCPlayerLayer alloc] initWithPlayer:_player andFrame:[UIScreen mainScreen].bounds previewImageRequired:YES];
    
    //TODO: Remove this when comes from the server
    NSString *posterPreview;
    if ([self.lastVideoURL rangeOfString:@"faces"].location == NSNotFound)
    {
        posterPreview = @"/9j/4AAQSkZJRgABAQAAAQABAAD//gAPTGF2YzU3LjQ4LjEwMf/bAEMAAgEBAgEBAgICAgICAgIDBQMDAwMDBgQEAwUHBgcHBwYHBwgJCwkICAoIBwcKDQoKCwwMDAwHCQ4PDQwOCwwMDP/bAEMBAgICAwMDBgMDBgwIBwgMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDP/AABEIAEsAKgMBIgACEQEDEQH/xAAVAAEBAAAAAAAAAAAAAAAAAAAACP/EABQQAQAAAAAAAAAAAAAAAAAAAAD/xAAWAQEBAQAAAAAAAAAAAAAAAAAABgn/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCIwEG20AAAAAAAAAAAAAAAAAAAAAAAAAAAAf/Z";
    }
    else
    {
        posterPreview = @"/9j/4AAQSkZJRgABAQEBlQGWAAD//gAPTGF2YzU3LjQ4LjEwMf/bAEMABwUFBgUEBwYFBggHBwgKEQsKCQkKFQ8QDBEYFRoZGBUYFxseJyEbHSUdFxgiLiIlKCkrLCsaIC8zLyoyJyorKv/bAEMBBwgICgkKFAsLFCocGBwqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKv/AABEIAEsAKgMBIgACEQEDEQH/xAAZAAADAQEBAAAAAAAAAAAAAAAFBgcECAP/xAApEAABAwQBAwMEAwAAAAAAAAABAAIDBAUGESESMUETFCIHI1FhMnGR/8QAGAEAAwEBAAAAAAAAAAAAAAAAAgMEAQD/xAAdEQADAAMBAQEBAAAAAAAAAAAAAQIDETEhQRIi/9oADAMBAAIRAxEAPwCz19W2CIuJ1pTLKMscwvZE7/EazG9+hG6NjuSkKktsl2nL3gkErG3G9sqr0XqnJKwTl4Lu6MWX6hTU0rWzPOv2jsuDsfDvo5/pIuS4xJbiXsBGkM5XsHTRdsayyG5xN+Y2f2msTtIB2Fy1h2RzW+4Nje8gA/lWqLLIjCwmQfxHlVzW0aqE/KZH1F06NnW0dx2njhhb1DlAq4iovB8/JM1DSyCNpb2UeT+q0at9GqCKOSLsEl5xb4nUTz0jek0005hi05KmXTPmpngfhLU+jG/CCVZNJc3FnGiizcjqAwDrPAWC807veuJHlYQDpUJ6JmVGGv3e+T3cqvaA2Sia79KBw3DV1a/flWGwXUPtzNHwlZF6UYq+B+aLZ4Qm7UbJKN/UPC9nXQb0Vhutya2heSfCHTQ9pLpH8lpWR1b9flLfS3aL5NcPVrH9J8paNQdpy4QV0ImoImDgfKqWCVjqmNsbipB1bkAVU+njSx7CUNIONplLdZC9vWEoZkHUdE5oOuFS21EbKLZI7KUZ5We5e6KPlJVP6UXTpaJNV/encXHysvtgjFRa52AyFp0hp6gSNJ80mT1jpHlbGe5qmjvyrTh1tdFCxwCjWL81zN88rojFGN9qzgdkbtJcKMVJLhvr5JIKEknWgpRc7nG+7lsruN+VWMm+Nsfrjhc7X+aRt1eWvI+Smp/taOyX74P1dLQuth0W70kCR8Pqu7dys8lZUGm0ZXa0g5lf1H5FJxY3K6c87fT/2Q==";
    }
    
    __weak typeof(self) welf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSData *posterData = [[NSData alloc] initWithBase64EncodedString:posterPreview options:0];
        UIImage *posterImage = [UIImage imageWithData:posterData];
        UIImageView *posterImageView = [[UIImageView alloc] initWithImage:posterImage];
        posterImageView.frame = welf.view.bounds;
        [welf.videoView insertSubview:posterImageView atIndex:0];
    }];
}

#pragma mark - UI Setup

- (void)viewDidLoad
{
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.staticView.hidden = YES;
    
    _playerLayer.frame = self.view.bounds;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.videoView.layer addSublayer:_playerLayer];

    NSString *goToExploreSoundURL = [[NSBundle mainBundle] pathForResource:@"go_to_explore" ofType:@"mp3"];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:goToExploreSoundURL] error:nil];
    [_audioPlayer setNumberOfLoops:0];
    [_audioPlayer prepareToPlay];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kPrimeTimeLoaded object:nil];
    
    [self setupGestureRecognizers];
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
    __hasAppeared = YES;
    
    [self readyToPlay];
    [self setupObservers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidDisappear:animated];
 
    __hasAppeared = NO;
    
    [self.player pause];
    [self removeObservers];
    
    self.staticView.hidden = (self.player!=nil);
}

- (void)presentSwipeDownViewIfNeeded
{
    DDLogVerbose(@"");
    [self removeObservers];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kLi5SwipeDownExplainerViewPresented])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DiscoverViews" bundle:[NSBundle mainBundle]];
        SwipeDownToExploreViewController *explainer= [storyboard instantiateViewControllerWithIdentifier:@"SwipeDownExplainerView"];
        explainer.modalPresentationStyle = UIModalPresentationCurrentContext;
        [explainer setSearchInteractor:searchInteractor];
        [_audioPlayer play];
        __weak typeof(self) welf = self;
        [self presentViewController:explainer animated:NO completion:^{
            __strong typeof(welf) swelf = welf;
            [swelf hideVideo];
        }];
    }
    else
    {
        [_audioPlayer play];
        [self hideVideo];
    }
}

- (void)hideVideo
{
    if (_player)
    {
        self.staticView.hidden = NO;
        self.videoView.hidden = YES;
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        _player = nil;
    }
}

#pragma mark - Observers

- (void)setupObservers
{
    DDLogVerbose(@"");
    if (!__playerEndObserver && _player)
    {
        __weak typeof(self) welf = self;
        __playerEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *_Nonnull note) {
            [welf presentSwipeDownViewIfNeeded];
        }];
    }
}

- (void)removeObservers
{
    DDLogVerbose(@"");
    if (__playerEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:__playerEndObserver];
        __playerEndObserver = nil;
    }
}

#pragma mark - Player

- (void)readyToPlay
{
    DDLogVerbose(@"");
//    if (self.player.status == AVPlayerStatusReadyToPlay)
//    {
        if (__hasAppeared && self.player != nil)
        {
            [self.player play];
        }
        else
        {
            self.staticView.hidden = NO;
//            [self presentSwipeDownViewIfNeeded];
        }
//    }
}

- (void)bufferEmpty
{
    DDLogVerbose(@"");
}

- (void)bufferReady
{
    DDLogVerbose(@"");
}

- (void)failToLoadItem:(NSError *)error
{
    DDLogError(@"%@",error.description);
}

- (void)networkFail:(NSError *)error
{
    DDLogError(@"%@",error.description);
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers
{
    DDLogVerbose(@"");
    //User Profile Gesture Recognizer - Swipe Down from 0-100px
    profileInteractor = [[UserProfileDynamicInteractor alloc] initWithParentViewController:self];
    profilePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:profileInteractor action:@selector(userDidPan:)];
    [profilePanGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:profilePanGestureRecognizer];
    
    //Search Products Gesture Recognizer - Swipe Down from below 100px
    searchInteractor = [[ExploreDynamicInteractor alloc] initWithParentViewController:self];
    searchPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:searchInteractor action:@selector(userDidPan:)];
    [searchPanGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:searchPanGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touch = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (gestureRecognizer == profilePanGestureRecognizer)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        return (touch.y < 150) && (velocity.y > 0);
    }
    else if (gestureRecognizer == searchPanGestureRecognizer)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
        return (touch.y >= 150) && (fabs(degree) > 70.0) && (velocity.y > 0);
    }
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([[gestureRecognizer view] isKindOfClass:[UIScrollView class]])
    {
        if (otherGestureRecognizer == profilePanGestureRecognizer || otherGestureRecognizer == searchPanGestureRecognizer)
        {
            return YES;
        }
    }
    return (gestureRecognizer == profilePanGestureRecognizer &&
            (otherGestureRecognizer == searchPanGestureRecognizer));
}

#pragma mark - OS Actions

- (void)dealloc
{
    DDLogDebug(@"%p",self);
    [self removeObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
