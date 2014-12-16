//
//  VXWindowDragView.h
//  VLCX
//
//  Created by Guilherme Rambo on 15/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VXWindowDragView : NSView

@property (readonly) NSArray *extraControls;

- (void)addExtraControl:(id)control;
- (void)removeExtraControl:(id)control;

@end
