//
//  VXCommonDocument.m
//  VLCX
//
//  Created by Guilherme Rambo on 17/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXMediaDocument.h"

@implementation VXMediaDocument

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    // initialize a VLCMedia object with the file opened
    self.media = [VLCMedia mediaWithPath:url.path];
    
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
