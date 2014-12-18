//
//  VXControllerView.m
//  VLCX
//
//  Created by Guilherme Rambo on 15/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXControllerView.h"

// with this defined, the controller view will use NSLayoutConstraints to allow the user to move itself,
// with this not defined, the move will be done by setting the frameOrigin directly,
// when setting the frameOrigin directly, resizing the window will make the controller jump back to It's default position
#define USE_CONSTRAINTS_TO_MOVE_CONTROLLER

@implementation VXControllerView
{
    NSMutableArray *_userMoveConstraints;
    BOOL _removedCenteringConstraints;
    BOOL _userMovedWhileInFullscreen;
    
    NSSize _superviewSizeInFullscreen;
    NSSize _superviewSizeNotInFullscreen;
}

- (void)awakeFromNib
{
    // this view's visual effect should be active even when the window is not key
    self.state = NSVisualEffectStateActive;

    // round the corners by using a mask image
    self.maskImage = [NSImage imageNamed:@"controllerMask"];
    
    #ifdef USE_CONSTRAINTS_TO_MOVE_CONTROLLER
    // save our superview's initial frame
    _superviewSizeNotInFullscreen = self.superview.frame.size;
    
    self.superview.postsFrameChangedNotifications = YES;
    // save our superview's frame when it changes and the window is not in fullscreen
    [[NSNotificationCenter defaultCenter] addObserverForName:NSViewFrameDidChangeNotification object:self.superview queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (self.window.styleMask & NSFullScreenWindowMask) return;
        
        _superviewSizeNotInFullscreen = self.superview.frame.size;
    }];
    
    // when our window enters fullscreen, we save It's size so we can scale the user move constraints later, if needed
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidEnterFullScreenNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        _superviewSizeInFullscreen = self.superview.frame.size;
    }];
    
    // when the window is exiting fullscreen we need to update the constraints if the user moved the controller in fullscreen
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowWillExitFullScreenNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self scaleUserMoveConstraintsIfNeeded];
    }];
    #endif
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

#define kTitlebarHeight 22.0
// this view can be moved anywhere inside it's window when dragged
- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint where = [self convertRect:NSMakeRect(theEvent.locationInWindow.x, theEvent.locationInWindow.y, 0, 0) toView:self].origin;
    NSPoint origin = self.frame.origin;
    CGFloat deltaX = 0.0;
    CGFloat deltaY = 0.0;
    while ((theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES]) && (theEvent.type != NSLeftMouseUp)) {
        @autoreleasepool {
            NSPoint now = [self convertRect:NSMakeRect(theEvent.locationInWindow.x, theEvent.locationInWindow.y, 0, 0) toView:self].origin;
            deltaX += now.x - where.x;
            deltaY += now.y - where.y;
            if (fabs(deltaX) >= 1 || fabs(deltaY) >= 1) {
                origin.x += round(deltaX);
                origin.y += round(deltaY);
                
                CGFloat maxX = NSWidth(self.window.frame)-NSWidth(self.frame);
                CGFloat maxY = NSHeight(self.window.frame)-NSHeight(self.frame)-kTitlebarHeight;
                
                if (origin.x > maxX) origin.x = maxX;
                if (origin.x < 0) origin.x = 0;
                if (origin.y > maxY) origin.y = maxY;
                if (origin.y < 0) origin.y = 0;
                
                #ifdef USE_CONSTRAINTS_TO_MOVE_CONTROLLER
                // remove the constraints that center the controller inside it's superview
                if (!_removedCenteringConstraints) [self removeCenteringConstraints];
                
                // add constraints to satisfy the user's intention
                [self createOrUpdateConstraintsWithUserMoveToLeft:origin.x top:origin.y];
                #else
                [self setFrameOrigin:origin];
                #endif
                
                deltaX = 0.0;
                deltaY = 0.0;
            }
            where = now;
        }
    }
}

#ifdef USE_CONSTRAINTS_TO_MOVE_CONTROLLER
- (void)createOrUpdateConstraintsWithUserMoveToLeft:(CGFloat)x top:(CGFloat)y
{
    // remove old move constraints
    if (_userMoveConstraints) [self.superview removeConstraints:_userMoveConstraints];
    if (self.window.styleMask & NSFullScreenWindowMask) _userMovedWhileInFullscreen = YES;
    
    _userMoveConstraints = [[NSMutableArray alloc] init];
    
    NSDictionary *views = @{@"controllerView": self,
                            @"superview": self.superview};
    
    // define the horizontal constraints according to the user's intention
    NSString *horizontalConstraintsCode = [NSString stringWithFormat:@"|-(%.0f)-[controllerView]", x];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraintsCode
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views];
    
    // define the vertical constraints according to the user's intention
    NSString *verticalConstraintsCode = [NSString stringWithFormat:@"V:[controllerView]-(%.0f)-|", y];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalConstraintsCode
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views];
    
    [_userMoveConstraints addObjectsFromArray:horizontalConstraints];
    [_userMoveConstraints addObjectsFromArray:verticalConstraints];
    
    // add these constraints to our superview, thus moving the view where the user wants
    [self.superview addConstraints:_userMoveConstraints];
}

- (void)scaleUserMoveConstraintsIfNeeded
{
    if (!_superviewSizeNotInFullscreen.width ||
        !_superviewSizeNotInFullscreen.height ||
        !_userMovedWhileInFullscreen ||
        !_userMoveConstraints.count) return;
    
    // remove old move constraints
    if (_userMoveConstraints) [self.superview removeConstraints:_userMoveConstraints];
    
    // calculate the scale we need to apply to the constraints
    CGFloat widthScale = _superviewSizeNotInFullscreen.width/_superviewSizeInFullscreen.width;
    CGFloat heightScale = _superviewSizeNotInFullscreen.height/_superviewSizeInFullscreen.height;
    
    // apply the new scale to the constraints
    for (NSLayoutConstraint *constraint in _userMoveConstraints) {
        if (constraint.firstAttribute == NSLayoutAttributeBottom ||
            constraint.firstAttribute == NSLayoutAttributeTop) {
            constraint.constant *= heightScale;
        } else if (constraint.firstAttribute == NSLayoutAttributeLeading ||
                   constraint.firstAttribute == NSLayoutAttributeTrailing) {
            constraint.constant *= widthScale;
        }
    }
    
    // add the updated constraints
    [self.superview addConstraints:_userMoveConstraints];
    
    // reset the flag
    _userMovedWhileInFullscreen = NO;
}

- (void)removeCenteringConstraints
{
    for (NSLayoutConstraint *constraint in self.superview.constraints) {
        if (![constraint.secondItem isEqualTo:self]) continue;
        
        if (constraint.firstAttribute == NSLayoutAttributeCenterX ||
            constraint.firstAttribute == NSLayoutAttributeCenterY ||
            constraint.firstAttribute == NSLayoutAttributeBottom) {
            [self.superview removeConstraint:constraint];
            _removedCenteringConstraints = YES;
        }
    }
}
#endif

@end
