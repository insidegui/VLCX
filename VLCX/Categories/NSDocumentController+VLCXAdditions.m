//
//  VXAudioDocument.m
//  VLCX
//
//  Created by Guilherme Rambo on 17/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "NSDocumentController+VLCXAdditions.h"

static NSArray *_cachedSubtitlesFileTypes;

@implementation NSDocumentController (VLCXAdditions)

+ (NSDictionary *)documentInfoForExtension:(NSString *)pathExtension
{
    NSArray *types = [NSBundle mainBundle].infoDictionary[@"CFBundleDocumentTypes"];
    
    for (NSDictionary *type in types) {
        if ([type[@"CFBundleTypeExtensions"] containsObject:pathExtension]) {
            return type;
        }
    }
    
    return nil;
}

+ (NSString *)documentTypeNameForExtension:(NSString *)pathExtension
{
    NSDictionary *info = [self documentInfoForExtension:pathExtension];
    if (!info) return nil;
    
    return info[@"CFBundleTypeName"];
}

+ (Class)documentClassForExtension:(NSString *)pathExtension
{
    NSDictionary *info = [self documentInfoForExtension:pathExtension];
    if (!info) return NULL;
    
    return NSClassFromString(info[@"NSDocumentClass"]);
}

+ (NSArray *)subtitlesFileTypes
{
    if (!_cachedSubtitlesFileTypes) {
        NSMutableArray *fileTypes = [NSMutableArray new];
        
        for (NSDictionary *typeInfo in [NSBundle mainBundle].infoDictionary[@"CFBundleDocumentTypes"]) {
            // I know this is kind of hacky :3
            if ([typeInfo[@"CFBundleTypeIconFile"] isEqualToString:@"subtitle.icns"]) [fileTypes addObjectsFromArray:typeInfo[@"CFBundleTypeExtensions"]];
        }
        
        _cachedSubtitlesFileTypes = [fileTypes copy];
    }
    
    return _cachedSubtitlesFileTypes;
}

@end
