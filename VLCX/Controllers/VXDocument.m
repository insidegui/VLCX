//
//  Document.m
//  VLCX
//
//  Created by Guilherme Rambo on 15/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXDocument.h"
#import "VXControllerView.h"
#import "VXWindowDragView.h"
#import "VXPlaybackController.h"

@import VLCKit;

@interface VXDocument ()

@property (strong) VLCMediaPlayer *player;
@property (strong) VLCMedia *media;

@property (weak) IBOutlet VXWindowDragView *dragView;
@property (weak) IBOutlet VXControllerView *controllerView;
@property (strong) IBOutlet VLCVideoView *videoView;

@property (strong) IBOutlet VXPlaybackController *playbackController;

@end

@implementation VXDocument

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

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    // initialize a VLCMedia object with the file opened
    self.media = [VLCMedia mediaWithPath:url.path];
    
    return YES;
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSString *)windowNibName {
    return NSStringFromClass([self class]);
}

- (void)close
{
    // just make sure we are not called during deinitialization
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // we need to stop the player before we destroy everything
    [self.player stop];
    
    [super close];
}

- (IBAction)playOrPause:(id)sender
{
    [self.playbackController playOrPause:sender];
}

#pragma mark Volume Controls

/*
 volumeUpAction:, volumeDownAction: and muteAction: are not connected directly, they are routed to the First Responder in MainMenu.xib,
 so whatever VXDocument is the current First Responder will receive these actions when the menus are activated
 */
- (IBAction)volumeUpAction:(id)sender
{
    [self.playbackController volumeUp];
}

- (IBAction)volumeDownAction:(id)sender
{
    [self.playbackController volumeDown];
}

- (IBAction)muteAction:(id)sender
{
    if (self.player.audio.isMuted) {
        [sender setState:NSOffState];
        [self.player.audio setMute:NO];
    } else {
        [sender setState:NSOnState];
        [self.player.audio setMute:YES];
    }
}

@end
