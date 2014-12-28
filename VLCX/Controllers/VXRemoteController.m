//
//  VXRemoteControl.m
//  VLCX
//
//  Created by Guilherme Rambo on 28/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXRemoteController.h"
#import "AppleRemote.h"

NSString *VXRemoteControlWantsToPlayNotification            = @"VXRemoteControlWantsToPlayNotification";
NSString *VXRemoteControlWantsToShowTheMenuNotification     = @"VXRemoteControlWantsToShowTheMenuNotification";
NSString *VXRemoteControlWantsToGoUpNotification            = @"VXRemoteControlWantsToGoUpNotification";
NSString *VXRemoteControlWantsToGoDownNotification          = @"VXRemoteControlWantsToGoDownNotification";
NSString *VXRemoteControlWantsToGoForwardNotification       = @"VXRemoteControlWantsToGoForwardNotification";
NSString *VXRemoteControlWantsToGoBackwardNotification      = @"VXRemoteControlWantsToGoBackwardNotification";
NSString *VXRemoteControlWantsToEnterNotification           = @"VXRemoteControlWantsToEnterNotification";
NSString *VXRemoteControlIsHoldingEnterNotification         = @"VXRemoteControlIsHoldingEnterNotification";

const int64_t kDebounceDelay = (int64_t)(0.1 * NSEC_PER_SEC);

@interface VXRemoteController ()

@property (strong) AppleRemote *remoteControl;
@property (assign, getter=isDebouncing) BOOL debouncing;

@end

@implementation VXRemoteController

+ (instancetype)sharedController
{
    static VXRemoteController *_instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[VXRemoteController alloc] init];
    });
    
    return _instance;
}

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    self.remoteControl = [[AppleRemote alloc] initWithDelegate:self];
    
    return self;
}

- (void)appBecameActive
{
    [self.remoteControl startListening:self];
}

- (void)appResignedActive
{
    [self.remoteControl stopListening:self];
}

#pragma mark Private Methods

- (void)sendRemoteButtonEvent:(RemoteControlEventIdentifier)event pressedDown:(BOOL)pressedDown remoteControl:(RemoteControl *)remoteControl
{
    if (!pressedDown) return;
    
    // we need to impose a delay between button events because they fire very quickly, this is called "deboucing"
    if (self.isDebouncing) return;
    
    self.debouncing = YES;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    switch (event) {
        case kRemoteButtonPlay:
            [nc postNotificationName:VXRemoteControlWantsToPlayNotification object:self];
            break;
        case kRemoteButtonMenu:
            [nc postNotificationName:VXRemoteControlWantsToShowTheMenuNotification object:self];
            break;
        case kRemoteButtonPlus:
        case kRemoteButtonPlus_Hold:
            [nc postNotificationName:VXRemoteControlWantsToGoUpNotification object:self];
            break;
        case kRemoteButtonMinus:
        case kRemoteButtonMinus_Hold:
            [nc postNotificationName:VXRemoteControlWantsToGoDownNotification object:self];
            break;
        case kRemoteButtonRight:
            [nc postNotificationName:VXRemoteControlWantsToGoForwardNotification object:self];
            break;
        case kRemoteButtonLeft:
            [nc postNotificationName:VXRemoteControlWantsToGoBackwardNotification object:self];
            break;
        case kRemoteButtonEnter:
            [nc postNotificationName:VXRemoteControlWantsToEnterNotification object:self];
            break;
        case kRemoteButtonEnter_Hold:
            [nc postNotificationName:VXRemoteControlIsHoldingEnterNotification object:self];
            break;
        default:
            break;
    }
    
    // allow only one button event every 0.1s to avoid repetition issues
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kDebounceDelay), dispatch_get_main_queue(), ^{
        self.debouncing = NO;
    });
}

@end
