//
//  VXVideoAdjustmentsController.h
//  VLCX
//
//  Created by Guilherme Rambo on 19/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@import VLCKit;

@interface VXVideoAdjustmentsController : NSViewController

@property (assign, getter=isPanelVisible) BOOL panelVisible;
@property (nonatomic, weak) VLCMediaPlayer *player;

- (void)togglePanelVisibility;

@end
