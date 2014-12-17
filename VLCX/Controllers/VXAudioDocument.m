//
//  VXAudioDocument.m
//  VLCX
//
//  Created by Guilherme Rambo on 17/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXAudioDocument.h"

@implementation VXAudioDocument

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    
    [super windowControllerDidLoadNib:aController];
    
    self.player = [[VLCMediaPlayer alloc] init];
    
    // tell the playbackController to control our player
    [self.playbackController setRepresentedObject:self.player];
    
    // the playbackController will get the media delegate callbacks
    self.media.delegate = self.playbackController;
    
    // at this point we already have a VLCMedia object initialized because readFromURL: is called before windowControllerDidLoadNib:
    [self.player setMedia:self.media];
    
    // start playing after a short delay,
    // this short delay ensures there are no audio glitches when starting the playback
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

@end
