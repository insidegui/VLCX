//
//  VXRemoteControl.h
//  VLCX
//
//  Created by Guilherme Rambo on 28/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *VXRemoteControlWantsToPlayNotification;
NSString *VXRemoteControlWantsToShowTheMenuNotification;
NSString *VXRemoteControlWantsToGoUpNotification;
NSString *VXRemoteControlWantsToGoDownNotification;
NSString *VXRemoteControlWantsToGoForwardNotification;
NSString *VXRemoteControlWantsToGoBackwardNotification;
NSString *VXRemoteControlWantsToEnterNotification;
NSString *VXRemoteControlIsHoldingEnterNotification;

@interface VXRemoteController : NSObject

+ (instancetype)sharedController;

- (void)appBecameActive;
- (void)appResignedActive;

@end
