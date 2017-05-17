//
//  MAKWindow.m
//  MAKWindow
//
//  Created by Martin Klöpfel on 18.10.13.
//  Copyright (c) 2013 Martin Klöpfel. All rights reserved.
//

#import "MAKWindow.h"

#import "NSObject+MAKObjectCaching.h"


NSString *const MAKWindowReceivedMotionShakeEventNotification = @"MAKWindowReceivedMotionShakeEventNotification";
NSString *const MAKWindowReceivedRemoteControlEventNotification = @"MAKWindowReceivedRemoteControlEventNotification";
NSString *const MAKWindowRemoteControlEventSubtypeUserInfoKey = @"MAKWindowRemoteControlEventSubtype";

NSString *const MAKTouchHighlightingViewKey = @"MAKTouchHighlightingView";


@interface MAKWindow ()

@property (nonatomic, copy) NSSet *allTouches;

@end


@implementation MAKWindow

#pragma mark - UIWindow methods

- (void)sendEvent:(UIEvent *)event
{
    switch (event.type)
    {
        case UIEventTypeTouches:
            
            self.allTouches = [event allTouches];//.allObjects; //.allObjects.lastObject;
            
            if (self.shouldVisualizeTouches)
            {
                for(UITouch *touch in [event allTouches])
                    [self updateTouchHighlightingViewsWithTouch:touch];
            }
            break;
        case UIEventTypeMotion:
            
            if (event.subtype == UIEventSubtypeMotionShake)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:MAKWindowReceivedMotionShakeEventNotification object:self];
            }
            break;
            
        case UIEventTypeRemoteControl:
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MAKWindowReceivedRemoteControlEventNotification object:self userInfo:@{MAKWindowRemoteControlEventSubtypeUserInfoKey : @(event.subtype)}];
            break;
    }
    
    [super sendEvent:event];
}


#pragma mark - Private methods

- (void)updateTouchHighlightingViewsWithTouch:(UITouch *)touch
{
    UIView *touchHighlightingView = [touch cachingObjectForKey:MAKTouchHighlightingViewKey];
    
    if (!touchHighlightingView)
    {
        touchHighlightingView = [self createTouchHighlightingView];
        [touch setCachingObject:touchHighlightingView forKey:MAKTouchHighlightingViewKey];
    }
    
    if (!touchHighlightingView.superview)
        [self showHighlightingView:touchHighlightingView];
    
    switch (touch.phase)
    {
        case UITouchPhaseBegan:
        case UITouchPhaseMoved:
        case UITouchPhaseStationary:
            touchHighlightingView.center = [touch locationInView:self];
            break;
        case UITouchPhaseCancelled:
        case UITouchPhaseEnded:
            [self hideHighlightingView:touchHighlightingView];
            [touch removeCachingObjectForKey:MAKTouchHighlightingViewKey];
            break;
    }
}

- (void)showHighlightingView:(UIView *)view
{
    [self addSubview:view];
    view.alpha = 0.0;
    view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.alpha = 1.0;
        view.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)hideHighlightingView:(UIView *)view
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionOverrideInheritedCurve animations:^{
        view.alpha = 0.0;
        view.transform = CGAffineTransformMakeScale(2.0, 2.0);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}


- (UIView *)createTouchHighlightingView
{
    return [[UIImageView alloc] initWithImage:[self imageForTouchHighlighting]];
}

- (UIImage *)imageForTouchHighlighting
{
    static UIImage *image = nil;
    
    if (!image)
    {
        CGSize size = CGSizeMake(40.0, 40.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        
        CGFloat comps[] = {1.0,0.0,0.0,1.0,    1.0,0.0,0.0,0.0};
        CGFloat locs[] = {0,1};
        CGGradientRef gradient = CGGradientCreateWithColorComponents(space, comps, locs, 2);
        
        CGContextDrawRadialGradient(context, gradient, CGPointMake(size.width*0.5, size.height*0.5) , 0.0, CGPointMake(size.width*0.5, size.height*0.5), size.width*0.5, 0);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

@end
