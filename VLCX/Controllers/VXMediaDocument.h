//
//  VXCommonDocument.h
//  VLCX
//
//  Created by Guilherme Rambo on 17/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VXPlaybackController.h"

@import VLCKit;

/**
 VXMediaDocument represents a common ground for both audio and video documents
 */
@interface VXMediaDocument : NSDocument

@property (strong) VLCMediaPlayer *player;
@property (strong) VLCMedia *media;

@property (strong) IBOutlet VXPlaybackController *playbackController;

// the URL, if this document represents an internet document
@property (nonatomic, copy) NSURL *internetURL;

- (instancetype)initWithType:(NSString *)type internetURL:(NSURL *)anURL;

@end