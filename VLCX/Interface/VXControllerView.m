//
//  VXControllerView.m
//  VLCX
//
//  Created by Guilherme Rambo on 15/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXControllerView.h"

@implementation VXControllerView

- (void)awakeFromNib
{
    // this view's visual effect should be active even when the window is not key
    self.state = NSVisualEffectStateActive;
    
    // round the corners by using a mask image
    self.maskImage = [NSImage imageNamed:@"controllerMask"];
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
                
                self.frameOrigin = origin;
                deltaX = 0.0;
                deltaY = 0.0;
            }
            where = now;
        }
    }
}

@end
