//
//  CardUIView.m
//  li5
//
//  Created by Martin Cocaro on 6/20/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "CardUIView.h"

#define sign(a) ( ( (a) < 0 )  ?  -1   : ( (a) > 0 ) )

@interface CardUIView ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGPoint initialPanPoint;

@end

@implementation CardUIView

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
    self.layer.cornerRadius = 5.0;
    _initialPanPoint = CGPointZero;
    
    [self __setupGestureRecognizers];
}

- (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)updateConstraints
{
    [super updateConstraints];
}

#pragma mark - Gesture Recognizers

- (void)__setupGestureRecognizers
{
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:_panGestureRecognizer];
}

- (void)handlePan:(UIPanGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        _initialPanPoint = [sender locationInView: self];
        CGPoint newAnchorPoint = CGPointMake(_initialPanPoint.x / self.bounds.size.width, _initialPanPoint.y / self.bounds.size.height);
        CGPoint oldPosition = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x, self.bounds.size.height * self.layer.anchorPoint.y);
        CGPoint newPosition = CGPointMake(self.bounds.size.width * newAnchorPoint.x, self.bounds.size.height * newAnchorPoint.y);
        self.layer.anchorPoint = newAnchorPoint;
        self.layer.position = CGPointMake(self.layer.position.x - oldPosition.x + newPosition.x, self.layer.position.y - oldPosition.y + newPosition.y);
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint dragDistance = [sender translationInView:self.superview];
        [self __updateCenterPositionOfDraggingCard:dragDistance];
    }
    else
    {
        CGPoint dragDistance = [sender translationInView:self.superview];
        CGPoint velocity = [sender velocityInView:self];
        [self __finishedDragging:dragDistance withVelocity:velocity];
        _initialPanPoint = CGPointZero;
    }
}

//Change position of dragged card
- (void)__updateCenterPositionOfDraggingCard:(CGPoint)dragDistance
{
    double animationDirectionY = (_initialPanPoint.x >= self.bounds.size.width/2)?sign(dragDistance.y):-sign(dragDistance.y);
    double animationDirectionX = (_initialPanPoint.y >= self.bounds.size.height/2)?-sign(dragDistance.x):sign(dragDistance.x);
    
    CGFloat rotationMax = M_PI / 4;
    CGFloat defaultRotationAngle = M_PI / 6;
    CGFloat rotationStrengthX = fabs(MIN(dragDistance.x / CGRectGetWidth(self.bounds), rotationMax));
    CGFloat rotationStrengthY = fabs(MIN(dragDistance.y / CGRectGetHeight(self.bounds), rotationMax));
    CGFloat rotationAngle =  defaultRotationAngle * (rotationStrengthY*animationDirectionY - rotationStrengthX*animationDirectionX);
    
    DDLogDebug(@"size: %@",NSStringFromCGSize(self.bounds.size));
    DDLogDebug(@"_initialPanPoint: %@",NSStringFromCGPoint(_initialPanPoint));
    DDLogDebug(@"animationDirection: (%f,%f)",animationDirectionX,animationDirectionY);
    DDLogDebug(@"rotationStrength: (%f,%f)",rotationStrengthX, rotationStrengthY);
    DDLogDebug(@"dragDistance: %@",NSStringFromCGPoint(dragDistance));
    DDLogDebug(@"rotationAngle: %f",rotationAngle * 180 / M_PI);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformRotate(CGAffineTransformTranslate(CGAffineTransformIdentity, dragDistance.x, dragDistance.y), rotationAngle);
    }];
}

- (void)__finishedDragging:(CGPoint)dragDistance withVelocity:(CGPoint)velocity
{
    BOOL shouldSnapBack = fabs(velocity.x) < 50 && fabs(velocity.y) < 50;
    if (shouldSnapBack)
    {
        [UIView animateWithDuration:0.25
                              delay:0.0
             usingSpringWithDamping:.5
              initialSpringVelocity:.8
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.transform = CGAffineTransformIdentity;
                         }
                         completion:nil
         ];
    }
    else
    {
//        CGFloat velocityMagnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
//        UIOffsetMake(finalPoint.x - center.x, finalPoint.y - center.y)
//        CGRectIntersectsRect(gesture.view.superview.bounds, gesture.view.frame
        CGFloat remainingx = self.superview.bounds.size.width - fabs(dragDistance.x);
        CGFloat remainingy = self.superview.bounds.size.height - fabs(dragDistance.y);
        [UIView animateWithDuration:0.5 animations:^{
            self.layer.position = CGPointMake(self.layer.position.x + sign(velocity.x)*remainingx,self.layer.position.y + sign(velocity.y)*remainingy);
        } completion:^(BOOL finished) {
            [self __dismiss];
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return (gestureRecognizer == _panGestureRecognizer);
}

- (void)__dismiss
{
    __weak typeof(self) welf = self;
    [[self parentViewController] dismissViewControllerAnimated:NO completion:^{
        __strong typeof(welf) swelf = welf;
        if (swelf.delegate)
        {
            [swelf.delegate cardDismissed];
        }
    }];
}

@end
