//
//  VXMenuController.m
//  VLCX
//
//  Created by Guilherme Rambo on 17/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXMenuController.h"

NSInteger const kMainMenuAudioItemTag = 11;
NSInteger const kMainMenuAudioTracksItemTag = 22;
NSInteger const kMainMenuSubtitlesItemTag = 33;

@interface VXMenuController ()

// audio and subtitle menus
@property (weak) IBOutlet NSMenu *audioOptionsMenu;
@property (weak) IBOutlet NSMenu *audioTracksMenu;
@property (weak) IBOutlet NSMenu *subtitleTracksMenu;
// audio and subtitle menus in main menu
@property (readonly) NSMenu *mainMenuAudioMenu;
@property (readonly) NSMenu *mainMenuAudioTracksMenu;
@property (readonly) NSMenu *mainMenuSubtitlesMenu;

@end

@implementation VXMenuController

- (void)setPlayer:(VLCMediaPlayer *)player
{
    _player = player;
    
    [self setupAudioTracksMenu];
    [self setupSubtitleTracksMenu];
}

// the "Audio" menu item in the main menu
- (NSMenu *)mainMenuAudioMenu
{
    return [[NSApp mainMenu] itemWithTag:kMainMenuAudioItemTag].submenu;
}

// the "Audio Track" menu item inside the "Audio" menu
- (NSMenu *)mainMenuAudioTracksMenu
{
    return [self.mainMenuAudioMenu itemWithTag:kMainMenuAudioTracksItemTag].submenu;
}

// the "Subtitles" menu item inside the "Audio" menu
- (NSMenu *)mainMenuSubtitlesMenu
{
    return [self.mainMenuAudioMenu itemWithTag:kMainMenuSubtitlesItemTag].submenu;
}

- (void)setupAudioTracksMenu
{
    if (self.player.audioTrackNames.count <= 0) return;
    
    [self.audioTracksMenu removeAllItems];
    [self.mainMenuAudioTracksMenu removeAllItems];
    
    for (NSString *trackName in self.player.audioTrackNames) {
        // create an item with the track name as it's title
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:trackName action:@selector(audioTrackMenuItemAction:) keyEquivalent:@""];
        item.target = self;
        // the tag will be the index of the track in the audioTrackNames array
        item.tag = [self.player.audioTrackNames indexOfObject:trackName];
        
        // if the current audio track is this one, tick the item :)
        if (item.tag == [self.player.audioTrackIndexes indexOfObject:@(self.player.currentAudioTrackIndex)]) [item setState:NSOnState];
        
        [self.audioTracksMenu addItem:item];
        [self.mainMenuAudioTracksMenu addItem:[item copy]];
    }
}

- (void)setupSubtitleTracksMenu
{
    if (self.player.videoSubTitlesNames.count <= 0) return;
    
    [self.subtitleTracksMenu removeAllItems];
    [self.mainMenuSubtitlesMenu removeAllItems];
    
    for (NSString *trackName in self.player.videoSubTitlesNames) {
        // ^^^^^^ same thing as above (setupAudioTracksMenu) ^^^^^^
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:trackName action:@selector(subtitlesTrackMenuItemAction:) keyEquivalent:@""];
        item.target = self;
        item.tag = [self.player.videoSubTitlesNames indexOfObject:trackName];
        if (item.tag == [self.player.videoSubTitlesIndexes indexOfObject:@(self.player.currentVideoSubTitleIndex)]) [item setState:NSOnState];
        
        [self.subtitleTracksMenu addItem:item];
        [self.mainMenuSubtitlesMenu addItem:[item copy]];
    }
}

- (void)audioTrackMenuItemAction:(id)sender
{
    // first untick all menu items
    for (NSMenuItem *item in self.audioTracksMenu.itemArray) [item setState:NSOffState];
    for (NSMenuItem *item in self.mainMenuAudioTracksMenu.itemArray) [item setState:NSOffState];
    
    // now tick the current track menu item
    self.player.currentAudioTrackIndex = [self.player.audioTrackIndexes[[sender tag]] integerValue];
    [sender setState:NSOnState];
}

- (void)subtitlesTrackMenuItemAction:(id)sender
{
    // first untick all menu items
    for (NSMenuItem *item in self.subtitleTracksMenu.itemArray) [item setState:NSOffState];
    for (NSMenuItem *item in self.mainMenuSubtitlesMenu.itemArray) [item setState:NSOffState];
    
    // now tick the current track menu item
    self.player.currentVideoSubTitleIndex = [self.player.videoSubTitlesIndexes[[sender tag]] integerValue];
    [sender setState:NSOnState];
}

@end
