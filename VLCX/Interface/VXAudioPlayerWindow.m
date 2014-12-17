//
//  VXAudioPlayerWindow.m
//  VLCX
//
//  Created by Guilherme Rambo on 17/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXAudioPlayerWindow.h"

// private class :3
@interface NSThemeFrame : NSView
- (NSTextField *)_titleTextField;
@end

@interface VXAudioPlayerWindowFrame : NSThemeFrame
@end

@implementation VXAudioPlayerWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if (!(self = [super initWithContentRect:contentRect styleMask:aStyle|NSFullSizeContentViewWindowMask backing:bufferingType defer:flag])) return nil;
    
    self.titlebarAppearsTransparent = YES;
    self.movableByWindowBackground = YES;
    
    return self;
}

- (NSThemeFrame *)themeFrame
{
    return (NSThemeFrame *)[self.contentView superview];
}

+ (Class)frameViewClassForStyleMask:(NSUInteger)aMask
{
    return [VXAudioPlayerWindowFrame class];
}

- (BOOL)_usesCustomDrawing
{
    return NO;
}

@end

@implementation VXAudioPlayerWindowFrame

- (NSColor *)_currentTitleColor
{
    return [NSColor secondaryLabelColor];
}

- (NSTextField *)_titleTextField
{
    NSTextField *ttf = [super _titleTextField];
    [[ttf cell] setBackgroundStyle:NSBackgroundStyleLowered];
    
    return ttf;
}

@end
