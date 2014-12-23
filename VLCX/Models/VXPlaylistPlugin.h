//
//  PlaylistPlugin.h
//  VLCX
//
//  Created by Guilherme Rambo on 22/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

@import Foundation;

typedef void(^VXPlaylistParserCompletionHandler)(NSArray *playlistItems, NSError *error);

/**
 @protocol VXPlaylistPlugin
 @abstract VXPlaylistPlugin is the protocol that playlist parser plugins must implement
 */
@protocol VXPlaylistPlugin <NSObject>

+ (BOOL)canWorkWithData:(NSData *)data;
+ (void)parsePlaylistWithData:(NSData *)data completionHandler:(VXPlaylistParserCompletionHandler)callback;

@end
