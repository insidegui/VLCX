//
//  VXPlaylistDocument.m
//  VLCX
//
//  Created by Guilherme Rambo on 21/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXPlaylistDocument.h"
#import "VXPlaylistParser.h"
#import "VXPlaylistItem.h"
#import "VXPlaylist.h"
#import "VXRemoteController.h"

NSString *VLCXPlaylistUTI = @"br.com.guilhermerambo.VLCX.Playlist";

@import VLCKit;

@interface VXPlaylistDocument () <VLCMediaDelegate>

@property (strong) VXPlaylist *playlist;
@property (weak) VXPlaylistItem *currentItem;
@property (assign) NSUInteger mediaIndex;

@end

@implementation VXPlaylistDocument

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    self.mediaIndex = -1;
    
    return self;
}

- (NSString *)windowNibName {
    return @"VXVideoDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    if (self.playlist.items.count) {
        [self nextItem:nil];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserverForName:VXRemoteControlWantsToGoForwardNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self nextItem:nil];
    }];
    [nc addObserverForName:VXRemoteControlWantsToGoBackwardNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self previousItem:nil];
    }];
    
    [super windowControllerDidLoadNib:aController];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSError __block *parseError;
    if (![VXPlaylistParser canWorkWithData:data]) {
        parseError = [NSError errorWithDomain:@"VLCX"
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Sorry, I can't open that playlist", @"Sorry, I can't open that playlist")}];
    }
    
    [VXPlaylistParser parsePlaylistWithData:data completionHandler:^(NSArray *playlistItems, NSError *error) {
        if (error) {
            parseError = error;
            return;
        }
        
        self.playlist = [VXPlaylist playlistWithItemsAsDictionaries:playlistItems];
    }];
    
    if (parseError) {
        *outError = parseError;
        return NO;
    }
    
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    // TODO: support saving to other playlist formats
    if (![typeName isEqualToString:VLCXPlaylistUTI]) return nil;
    
    if (!self.playlist) self.playlist = [[VXPlaylist alloc] initWithItems:nil];
    
    NSMutableArray *itemDicts = [NSMutableArray new];
    for (VXPlaylistItem *item in self.playlist.items) {
        [itemDicts addObject:[item dictionaryRepresentation]];
    }
    
    return [NSKeyedArchiver archivedDataWithRootObject:[itemDicts copy]];
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.playlist forKey:@"playlist"];
}

- (void)restoreStateWithCoder:(NSCoder *)coder
{
    [super restoreStateWithCoder:coder];
    
    self.playlist = [coder decodeObjectForKey:@"playlist"];
}

- (void)close
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super close];
}

#pragma mark Playlist Actions

- (IBAction)nextItem:(id)sender
{
    [self playItemAtIndex:self.mediaIndex+1];
}

- (IBAction)previousItem:(id)sender
{
    [self playItemAtIndex:self.mediaIndex-1];
}

- (void)playItemAtIndex:(NSInteger)idx
{
    BOOL wasPlaying = NO;
    if (self.player.playing) {
        [self.player stop];
        wasPlaying = YES;
    }
    
    if (idx >= self.playlist.items.count) idx = 0;
    if (idx < 0) idx = 0;
    
    self.mediaIndex = idx;
    
    self.currentItem = self.playlist.items[self.mediaIndex];
    self.media = [VLCMedia mediaWithPath:self.currentItem.path];
    self.media.delegate = self.playbackController;
    self.player.media = self.media;
    
    if (wasPlaying) [self.player play];
}

@end
