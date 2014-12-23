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

NSString *VLCXPlaylistUTI = @"br.com.guilhermerambo.VLCX.Playlist";

@import VLCKit;

@interface VXPlaylistDocument () <VLCMediaDelegate>

@property (strong) VXPlaylist *playlist;

@end

@implementation VXPlaylistDocument

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    return self;
}

- (NSString *)windowNibName {
    return NSStringFromClass([self class]);
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
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

@end
