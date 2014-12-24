//
//  VXPlayerWindow.h
//  VLCX
//
//  Created by Guilherme Rambo on 15/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VXPlayerWindow : NSWindow

@property (assign) BOOL enableControlHiding;

@property (readonly) BOOL titlebarVisible;

- (void)hideTitlebarAnimated:(BOOL)animated;
- (void)showTitlebarAnimated:(BOOL)animated;
- (void)sizeToFitVideoSize:(NSSize)videoSize animated:(BOOL)animate;

@end
