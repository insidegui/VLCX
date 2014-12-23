//
//  VXPlaylist.m
//
//  Created by Guilherme Rambo on 21/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXPlaylist.h"
#import "VXPlaylistItem.h"

@interface VXPlaylist ()

@property (strong) NSMutableArray *mutableItems;

@end

@implementation VXPlaylist
{
    NSNumber *_length;
}

+ (instancetype)playlistWithItemsAsDictionaries:(NSArray *)itemDicts
{
    VXPlaylist *playlist = [[VXPlaylist alloc] initWithItems:nil];
    
    for (NSDictionary *dict in itemDicts) {
        [playlist addItem:[[VXPlaylistItem alloc] initWithDictionaryRepresentation:dict]];
    }
    
    return playlist;
}

- (instancetype)initWithItems:(NSArray *)items
{
    if (!(self = [super init])) return nil;
    
    if (items) {
        self.mutableItems = [items mutableCopy];
    } else {
        self.mutableItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addItem:(VXPlaylistItem *)item
{
    [self.mutableItems addObject:item];
    _length = @(_length.longLongValue+item.length.longLongValue);
}

- (void)removeItem:(VXPlaylistItem *)item
{
    [self.mutableItems removeObject:item];
    _length = @(_length.longLongValue-item.length.longLongValue);
}

- (NSNumber *)length
{
    if (!_length) {
        NSUInteger sum = 0;
        
        for (VXPlaylistItem *item in self.items) {
            sum += item.length.integerValue;
        }
        
        _length = @(sum);
    }

    return _length;
}

- (NSArray *)items
{
    return [self.mutableItems copy];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[VXPlaylist alloc] initWithItems:[self.items copy]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.items forKey:@"items"];
    if (_length) [aCoder encodeObject:_length forKey:@"length"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super init])) return nil;
    
    self.mutableItems = [[aDecoder decodeObjectForKey:@"items"] mutableCopy];
    _length = [aDecoder decodeObjectForKey:@"length"];
    
    return self;
}

@end
