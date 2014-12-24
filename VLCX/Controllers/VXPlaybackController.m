//
//  VXPlaybackController.m
//  VLCX
//
//  Created by Guilherme Rambo on 16/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXPlaybackController.h"
#import "VXPlayerWindow.h"
#import "VXMenuController.h"

@interface VXPlaybackController ()

@property (readonly) VXPlayerWindow *playerWindow;
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

// menu controller
@property (weak) IBOutlet VXMenuController *menuController;

@end

@implementation VXPlaybackController
{
    BOOL _buttonIsPause;
}

- (VLCMediaPlayer *)player
{
    return (VLCMediaPlayer *)self.representedObject;
}

- (VXPlayerWindow *)playerWindow
{
    return (VXPlayerWindow *)self.view.window;
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
    if (!self.player.media.length.intValue) return;
    
    VLCTime *newTime = [VLCTime timeWithInt:self.timeSlider.intValue];
    self.player.time = newTime;
    
    // wen the time is set manually, playerTimeChanged: is not called, so we have to call updateTimeLabels here
    [self updateTimeLabelsWithTime:newTime];
}

- (BOOL)mediaHasVideoTracks
{
    for (NSDictionary *track in self.player.media.tracksInformation) {
        if ([track[@"type"] isEqualToString:@"video"]) return YES;
    }
    
    return NO;
}

- (void)mediaDidFinishParsing:(VLCMedia *)aMedia
{
    if ([self mediaHasVideoTracks]) {
        if (self.player.videoSize.width > 0) {
            // set the player window's aspectRatio to the aspect ratio of the video
            self.view.window.aspectRatio = self.player.videoSize;
            
            // size the window to fit the video
            [self.playerWindow sizeToFitVideoSize:self.player.videoSize animated:YES];
        }
        
        if ([self.playerWindow respondsToSelector:@selector(setEnableControlHiding:)]) self.playerWindow.enableControlHiding = YES;
    } else {
        if ([self.playerWindow respondsToSelector:@selector(setEnableControlHiding:)]) {
            [self.playerWindow showTitlebarAnimated:YES];
            self.view.hidden = NO;
            self.view.animator.alphaValue = 1;
            self.playerWindow.enableControlHiding = NO;
        }
    }
    
    // disable the time slider if the total media time is unknown
    if (!self.player.media.length.intValue) self.timeSlider.enabled = NO;
    
    // set default volume level
    // TODO: add a preference and/or save previous level
    self.player.audio.volume = 100;
    
    // do an initial update on the time controls
    [self updateTimeControls];
    
    // populate the audio and subtitle menus
    self.menuController.player = self.player;
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
    if (self.player.media.length.intValue) {
        self.timeSlider.maxValue = self.player.media.length.intValue;
        self.timeSlider.intValue = self.player.time.intValue;
    }
    
    [self updateTimeLabels];
}

- (void)updateTimeLabels
{
    [self updateTimeLabelsWithTime:self.player.time];
}

- (void)updateTimeLabelsWithTime:(VLCTime *)time
{
    self.currentTimeLabel.stringValue = time.stringValue;
    self.timeLeftLabel.stringValue = [NSString stringWithFormat:@"-%@", [VLCTime timeWithInt:(self.player.media.length.intValue-time.intValue)].stringValue];
}

- (void)updateSubtitlesMenuAfterOpeningCustomSubtitle
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.menuController setupSubtitleTracksMenu];
    });
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
