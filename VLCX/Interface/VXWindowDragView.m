//
//  VXWindowDragView.m
//  VLCX
//
//  Created by Guilherme Rambo on 15/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXWindowDragView.h"
#import "VXPlayerWindow.h"

#define kHideControlsDelay 3.0f

@interface VXWindowDragView ()

@property (readonly) VXPlayerWindow *playerWindow;
@property (strong) NSTrackingArea *controlsTrackingArea;
@property (strong) NSTimer *hideControlsTimer;
@property (nonatomic, strong) NSMutableArray *internalExtraControls;

@end

@implementation VXWindowDragView

- (void)updateTrackingAreas
{
    if (self.controlsTrackingArea) [self removeTrackingArea:self.controlsTrackingArea];
    
    NSTrackingAreaOptions trackingOptions = NSTrackingActiveAlways|NSTrackingInVisibleRect|NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved;
    self.controlsTrackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                             options:trackingOptions
                                                               owner:self
                                                            userInfo:nil];
    [self addTrackingArea:self.controlsTrackingArea];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    // show the controls while the mouse is moving inside the view
    [self showControls];
    
    // make a timer so the controls disappear when the cursor is not moving for a while
    [self.hideControlsTimer invalidate];
    self.hideControlsTimer = nil;
    self.hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:kHideControlsDelay target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    // put our window in fullscreen when double clicked
    if (theEvent.clickCount != 2) return;
    
    [self.window toggleFullScreen:self];
}

- (void)showControls
{
    [NSAnimationContext beginGrouping];
    [self.playerWindow showTitlebarAnimated:YES];
    for (NSView *control in self.extraControls) {
        control.hidden = NO;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            control.animator.alphaValue = 1;
        } completionHandler:^{
        }];
    }
    [NSAnimationContext endGrouping];
}

- (void)hideControls
{
    if ([self.window respondsToSelector:@selector(enableControlHiding)]) {
        if (![(VXPlayerWindow *)self.window enableControlHiding]) {
            [self showControls];
            return;
        }
    }
    
    [NSAnimationContext beginGrouping];
    [self.playerWindow hideTitlebarAnimated:YES];
    for (NSView *control in self.extraControls) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            control.animator.alphaValue = 0;
        } completionHandler:^{
            control.hidden = YES;
        }];
    }
    [NSAnimationContext endGrouping];
    [NSCursor setHiddenUntilMouseMoves:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    // hide the controls when the mouse exits the view
    [self hideControls];
}

// moves the window when dragging this view
// we could have done this by setting movableByWindowBackground, but somehow VLCVideoView prevents this behaviour from working
- (void)mouseDragged:(NSEvent *)theEvent
{
    NSWindow *window = self.window;
    if (window.isMovableByWindowBackground || (window.styleMask & NSFullScreenWindowMask) == NSFullScreenWindowMask) {
        [super mouseDragged:theEvent];
        return;
    }
    
    NSPoint where = [window convertRectToScreen:NSMakeRect(theEvent.locationInWindow.x, theEvent.locationInWindow.y, 0, 0)].origin;
    NSPoint origin = window.frame.origin;
    CGFloat deltaX = 0.0;
    CGFloat deltaY = 0.0;
    while ((theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES]) && (theEvent.type != NSLeftMouseUp)) {
        @autoreleasepool {
            NSPoint now = [window convertRectToScreen:NSMakeRect(theEvent.locationInWindow.x, theEvent.locationInWindow.y, 0, 0)].origin;
            deltaX += now.x - where.x;
            deltaY += now.y - where.y;
            if (fabs(deltaX) >= 1 || fabs(deltaY) >= 1) {
                origin.x += deltaX;
                origin.y += deltaY;
                window.frameOrigin = origin;
                deltaX = 0.0;
                deltaY = 0.0;
            }
            where = now;
        }
    }
}

- (VXPlayerWindow *)playerWindow
{
    if (![self.window isKindOfClass:[VXPlayerWindow class]]) return nil;
    
    return (VXPlayerWindow *)self.window;
}

- (NSMutableArray *)internalExtraControls
{
    if (!_internalExtraControls) _internalExtraControls = [NSMutableArray new];
    
    return _internalExtraControls;
}

- (NSArray *)extraControls
{
    return [self.internalExtraControls copy];
}

- (void)addExtraControl:(id)control
{
    [self.internalExtraControls addObject:control];
}

- (void)removeExtraControl:(id)control
{
    [self.internalExtraControls removeObject:control];
}

@end
