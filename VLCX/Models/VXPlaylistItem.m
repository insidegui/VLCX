//
//  VXPlaylistItem.m
//
//  Created by Guilherme Rambo on 21/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXPlaylistItem.h"

@implementation VXPlaylistItem

- (instancetype)initWithTitle:(NSString *)title length:(NSNumber *)length path:(NSString *)path
{
    if (!(self = [super init])) return nil;
    
    self.title = title;
    self.length = length;
    self.path = path;
    
    return self;
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dict
{
    return [self initWithTitle:dict[@"title"] length:dict[@"length"] path:dict[@"path"]];
}

- (NSUInteger)hash
{
    return self.title.hash+self.length.hash+self.path.hash;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[VXPlaylistItem alloc] initWithTitle:self.title length:self.length path:self.path];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"title = %@\rlength = %@\rpath = %@", self.title, self.length, self.path];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.length forKey:@"length"];
    [aCoder encodeObject:self.path forKey:@"path"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super init])) return nil;
    
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.length = [aDecoder decodeObjectForKey:@"length"];
    self.path = [aDecoder decodeObjectForKey:@"path"];
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{@"title": self.title,
             @"length": self.length,
             @"path": self.path};
}

@end
