//
//  MAKWindow.h
//  MAKWindow
//
//  Created by Martin Klöpfel on 18.10.13.
//  Copyright (c) 2013 Martin Klöpfel. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString *const MAKWindowReceivedMotionShakeEventNotification;

extern NSString *const MAKWindowReceivedRemoteControlEventNotification;
extern NSString *const MAKWindowRemoteControlEventSubtypeUserInfoKey;


@interface MAKWindow : UIWindow

@property (nonatomic, copy, readonly) NSSet *allTouches;

@property (nonatomic, getter=shouldVisualizeTouches) BOOL visualizeTouches;


@end
