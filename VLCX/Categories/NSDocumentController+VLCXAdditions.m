//
//  VXAudioDocument.m
//  VLCX
//
//  Created by Guilherme Rambo on 17/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "NSDocumentController+VLCXAdditions.h"

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

@end
