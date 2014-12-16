//
//  VXPlaybackController.m
//  VLCX
//
//  Created by Guilherme Rambo on 16/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXPlaybackController.h"

@interface VXPlaybackController ()

@property (readonly) VLCMediaPlayer *player;

@property (weak) IBOutlet NSButton *playPauseButton;

// volume controls
@property (weak) IBOutlet NSButton *volumeMinButton;
@property (weak) IBOutlet NSButton *volumeMaxButton;
@property (weak) IBOutlet NSSlider *volumeSlider;

// time controls
@property (weak) IBOutlet NSTextField *currentTimeLabel;
@property (weak) IBOutlet NSTextField *timeLeftLabel;
@property (weak) IBOutlet NSSlider *timeSlider;

// audio and subtitle menus
@property (strong) IBOutlet NSMenu *audioOptionsMenu;
@property (strong) IBOutlet NSMenu *audioTracksMenu;
@property (weak) IBOutlet NSMenu *subtitleTracksMenu;

@end

@implementation VXPlaybackController
{
    BOOL _buttonIsPause;
}

- (VLCMediaPlayer *)player
{
    return (VLCMediaPlayer *)self.representedObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // we need to stop observing stuff when the window closes, so we don't crash
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowWillCloseNotification object:self.view.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // we want to be notified when the player's state or current time changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateChanged:) name:VLCMediaPlayerStateChanged object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerTimeChanged:) name:VLCMediaPlayerTimeChanged object:self.player];
}

- (IBAction)playOrPause:(id)sender {
    // if we are playing, pause, if we are paused, play. Simple, huh?
    if (self.player.isPlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

- (IBAction)volumeSliderAction:(id)sender {
    self.player.audio.volume = self.volumeSlider.intValue;
}

- (IBAction)volumeMinAction:(id)sender {
    self.volumeSlider.doubleValue = self.volumeSlider.minValue;
    [self volumeSliderAction:nil];
}

- (IBAction)volumeMaxAction:(id)sender {
    self.volumeSlider.doubleValue = self.volumeSlider.maxValue;
    [self volumeSliderAction:nil];
}

- (void)volumeUp
{
    self.volumeSlider.doubleValue += 10;
    [self volumeSliderAction:nil];
}

- (void)volumeDown
{
    self.volumeSlider.doubleValue -= 10;
    [self volumeSliderAction:nil];
}

- (IBAction)timeSliderAction:(id)sender {
    self.player.time = [VLCTime timeWithInt:self.timeSlider.intValue];
    
    // wen the time is set manually, playerTimeChanged: is not called, so we have to call updateTimeLabels here
    [self updateTimeLabels];
}

- (void)mediaDidFinishParsing:(VLCMedia *)aMedia
{
    if (self.player.videoSize.width > 0) {
        // set the player window's aspectRatio to the aspect ratio of the video
        self.view.window.aspectRatio = self.player.videoSize;
        
        // if the current size of the player window is not at the correct aspect ratio,
        // set the size of the player window to half the size of the video
        //
        // TODO: improve the sizing method, maybe use the screen size as a factor
        if (NSWidth(self.view.window.frame)/NSHeight(self.view.window.frame) != self.player.videoSize.width/self.player.videoSize.height) {
            [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x, self.view.window.frame.origin.y, round(self.player.videoSize.width*0.5), round(self.player.videoSize.height*0.5)) display:YES animate:NO];
        }
    }
    
    // do an initial update on the time controls
    [self updateTimeControls];
    
    // populate the audio and subtitle menus
    [self setupAudioTracksMenu];
    [self setupSubtitleTracksMenu];
}

- (void)playerStateChanged:(NSNotification *)aNotification
{
    switch (self.player.state) {
        case VLCMediaPlayerStatePlaying:
            [self playbackStarted];
            break;
        case VLCMediaPlayerStatePaused:
        case VLCMediaPlayerStateStopped:
            [self playbackPaused];
            break;
        case VLCMediaPlayerStateEnded:
            [self playbackEnded];
            break;
        default:
            break;
    }
}

- (void)playerTimeChanged:(NSNotification *)aNotification
{
    // make sure the button is in the "pause" state if we are playing
    if (self.player.isPlaying && !_buttonIsPause) {
        [self changePlayButtonGlyphTo:@"pause"];
        _buttonIsPause = YES;
    }
    
    [self updateTimeControls];
}

- (void)updateTimeControls
{
    self.timeSlider.maxValue = self.player.media.length.intValue;
    self.timeSlider.intValue = self.player.time.intValue;
    
    [self updateTimeLabels];
}

- (void)updateTimeLabels
{
    self.currentTimeLabel.stringValue = self.player.time.stringValue;
    self.timeLeftLabel.stringValue = self.player.remainingTime.stringValue;
}

- (void)setupAudioTracksMenu
{
    if (self.player.audioTrackNames.count <= 0) return;
    
    [self.audioTracksMenu removeAllItems];
    
    for (NSString *trackName in self.player.audioTrackNames) {
        // create an item with the track name as it's title
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:trackName action:@selector(audioTrackMenuItemAction:) keyEquivalent:@""];
        // the tag will be the index of the track in the audioTrackNames array
        item.tag = [self.player.audioTrackNames indexOfObject:trackName];
        
        // if the current audio track is this one, tick the item :)
        if (item.tag == [self.player.audioTrackIndexes indexOfObject:@(self.player.currentAudioTrackIndex)]) [item setState:NSOnState];
        
        [self.audioTracksMenu addItem:item];
    }
}

- (void)setupSubtitleTracksMenu
{
    if (self.player.videoSubTitlesNames.count <= 0) return;
    
    [self.subtitleTracksMenu removeAllItems];
    
    for (NSString *trackName in self.player.videoSubTitlesNames) {
        // ^^^^^^ same thing as above (setupAudioTracksMenu) ^^^^^^
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:trackName action:@selector(subtitlesTrackMenuItemAction:) keyEquivalent:@""];
        item.tag = [self.player.videoSubTitlesNames indexOfObject:trackName];
        if (item.tag == [self.player.videoSubTitlesIndexes indexOfObject:@(self.player.currentVideoSubTitleIndex)]) [item setState:NSOnState];
        
        [self.subtitleTracksMenu addItem:item];
    }
}

- (void)audioTrackMenuItemAction:(id)sender
{
    // first untick all menu items
    for (NSMenuItem *item in self.audioTracksMenu.itemArray) {
        [item setState:NSOffState];
    }
    
    // now tick the current track menu item
    self.player.currentAudioTrackIndex = [self.player.audioTrackIndexes[[sender tag]] integerValue];
    [sender setState:NSOnState];
}

- (void)subtitlesTrackMenuItemAction:(id)sender
{
    // first untick all menu items
    for (NSMenuItem *item in self.subtitleTracksMenu.itemArray) {
        [item setState:NSOffState];
    }
    
    // now tick the current track menu item
    self.player.currentVideoSubTitleIndex = [self.player.videoSubTitlesIndexes[[sender tag]] integerValue];
    [sender setState:NSOnState];
}

#pragma mark Playback States

- (void)changePlayButtonGlyphTo:(NSString *)glyphName
{
    self.playPauseButton.image = [NSImage imageNamed:glyphName];
    
    if ([glyphName isEqualToString:@"pause"]) {
        _buttonIsPause = YES;
    }
}

- (void)playbackStarted
{
    [self changePlayButtonGlyphTo:@"pause"];
    self.timeSlider.continuous = NO;
}

- (void)playbackPaused
{
    [self changePlayButtonGlyphTo:@"play"];
    self.timeSlider.continuous = YES;
}

- (void)playbackEnded
{
    [self playbackPaused];
}

@end
