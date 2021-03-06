//
//  VXPlayerWindow.m
//  VLCX
//
//  Created by Guilherme Rambo on 15/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXPlayerWindow.h"

#import <objc/runtime.h>

@interface VXPlayerWindow ()

@property (readonly) NSVisualEffectView *titlebarView;

@end

@interface VXPlayerWindowFrame : NSView
+ (void)installPlayerWindowTitleTextSwizzles;
@end

@interface VXPlayerWindowFrame (Swizzles)
- (NSBackgroundStyle)_NS_backgroundStyleForTitleTextField;
- (NSColor *)_NS_currentTitleColor;
@end

// this is just a hack so we can access titlebarView without warnings from the compiler,
// titlebarView is actually a property of NSThemeFrame, which is a subclass of NSView ;)
@interface NSView (Titlebar)
- (NSVisualEffectView *)titlebarView;
@end

@implementation VXPlayerWindow

+ (void)load
{
    [VXPlayerWindowFrame installPlayerWindowTitleTextSwizzles];
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if (!(self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) return nil;

    // default is to enable control hiding
    self.enableControlHiding = YES;
    
    // make the contentView the full size of the window
    self.styleMask |= NSFullSizeContentViewWindowMask;
    
    // make our titlebar dark
    self.titlebarView.material = NSVisualEffectMaterialDark;
    
    // the titlebar vibrancy effect should always be active
    self.titlebarView.state = NSVisualEffectStateActive;
    
    // start with the titlebar hidden
    [self hideTitlebarAnimated:NO];
    
    return self;
}

- (void)makeKeyAndOrderFront:(id)sender
{
    [super makeKeyAndOrderFront:sender];
    
    [self configureTitlebar];
}

- (void)configureTitlebar
{
    self.titlebarView.material = NSVisualEffectMaterialDark;
    self.titlebarView.state = NSVisualEffectStateActive;
}

- (void)hideTitlebarAnimated:(BOOL)animated
{
    // do not hide the titlebar when in fullscreen mode
    if ((self.styleMask & NSFullScreenWindowMask)) return;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        if (!animated) [context setDuration:0];
        
        self.titlebarView.animator.alphaValue = 0;
    } completionHandler:^{
        _titlebarVisible = NO;
        
        self.titlebarView.hidden = YES;
    }];
}

- (void)showTitlebarAnimated:(BOOL)animated
{
    self.titlebarView.hidden = NO;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        if (!animated) [context setDuration:0];
        
        self.titlebarView.animator.alphaValue = 1;
    } completionHandler:^{
        _titlebarVisible = YES;
    }];
}

- (NSVisualEffectView *)titlebarView
{
    // [self.contentView superview] is an instance of NSThemeFrame, which has a property called titlebarView
    return [[self.contentView superview] titlebarView];
}

- (void)sizeToFitVideoSize:(NSSize)videoSize animated:(BOOL)animate
{
    CGFloat wRatio, hRatio, resizeRatio;
    NSRect screenRect = [NSScreen mainScreen].frame;
    NSSize screenSize = screenRect.size;
    
    if (videoSize.width >= videoSize.height) {
        wRatio = screenSize.width / videoSize.width;
        hRatio = screenSize.height / videoSize.height;
    } else {
        wRatio = screenSize.height / videoSize.width;
        hRatio = screenSize.width / videoSize.height;
    }
    
    resizeRatio = MIN(wRatio, hRatio);
    
    NSSize newSize = NSMakeSize(videoSize.width*resizeRatio, videoSize.height*resizeRatio);
    
    CGFloat xPos = screenSize.width/2-newSize.width/2;
    CGFloat yPos = screenSize.height/2-newSize.height/2;
    NSRect newRect = NSMakeRect(xPos, yPos, newSize.width, newSize.height);
    
    [self setFrame:newRect display:YES animate:animate];
    [self center];
}

@end

@implementation VXPlayerWindowFrame

+ (void)installPlayerWindowTitleTextSwizzles
{
    Class targetClass = NSClassFromString(@"NSThemeFrame");
    NSArray *methodsToOverride = @[@"_backgroundStyleForTitleTextField", @"_currentTitleColor"];
    for (NSString *selector in methodsToOverride) {
        Method m1 = class_getInstanceMethod(targetClass, NSSelectorFromString(selector));
        Method m2 = class_getInstanceMethod([self class], NSSelectorFromString([selector stringByReplacingOccurrencesOfString:@"_" withString:@"_VX_"]));
        class_addMethod(targetClass, NSSelectorFromString([selector stringByReplacingOccurrencesOfString:@"_" withString:@"_NS_"]), method_getImplementation(m1), method_getTypeEncoding(m1));
        method_exchangeImplementations(m1, m2);
    }
}

- (NSBackgroundStyle)_VX_backgroundStyleForTitleTextField
{
    if ([self.window isKindOfClass:[VXPlayerWindow class]]) {
        return NSBackgroundStyleDark;
    } else {
        return [self _NS_backgroundStyleForTitleTextField];
    }
}

- (NSColor *)_VX_currentTitleColor
{
    if ([self.window isKindOfClass:[VXPlayerWindow class]]) {
        return [NSColor secondaryLabelColor];
    } else {
        return [self _NS_currentTitleColor];
    }
}

@end