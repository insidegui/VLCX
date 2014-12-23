//
//  VXPlaylistItem.h
//
//  Created by Guilherme Rambo on 21/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

@import Foundation;

@interface VXPlaylistItem : NSObject <NSCopying, NSCoding>

@property (copy) NSString *title;
@property (copy) NSNumber *length;
@property (copy) NSString *path;

- (instancetype)initWithTitle:(NSString *)title length:(NSNumber *)length path:(NSString *)path;
- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

@end
