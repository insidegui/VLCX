//
//  Document.m
//  VLCX
//
//  Created by Guilherme Rambo on 15/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXVideoDocument.h"
#import "VXControllerView.h"
#import "VXWindowDragView.h"

@interface VXVideoDocument ()

@property (weak) IBOutlet VXWindowDragView *dragView;
@property (weak) IBOutlet VXControllerView *controllerView;
@property (strong) IBOutlet VLCVideoView *videoView;

@end

@implementation VXVideoDocument

- (instancetype)init {
    if (!(self = [super init])) return nil;
    
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    
    // add the controllerView as an extra control so it fades out when the cursor leaves the window
    [self.dragView addExtraControl:self.controllerView];
    
    self.videoView.fillScreen = YES;
    
    self.player = [[VLCMediaPlayer alloc] initWithVideoView:self.videoView];
    
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
