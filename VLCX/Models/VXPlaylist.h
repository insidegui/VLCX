//
//  VXPlaylist.h
//
//  Created by Guilherme Rambo on 21/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

@import Foundation;

@class VXPlaylistItem;

@interface VXPlaylist : NSObject <NSCopying, NSCoding>

@property (readonly) NSArray *items;
@property (readonly) NSNumber *length;

+ (instancetype)playlistWithItemsAsDictionaries:(NSArray *)itemDicts;

- (instancetype)initWithItems:(NSArray *)items;
- (void)addItem:(VXPlaylistItem *)item;
- (void)removeItem:(VXPlaylistItem *)item;

@end
