//
//  VXPlaylistParser.m
//  VLCX
//
//  Created by Guilherme Rambo on 22/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXPlaylistParser.h"

NSString *VXPlaylistPluginExtension = @"plparser";

@implementation VXPlaylistParser
{
    NSArray *_pluginClasses;
}

#pragma mark Lifecycle and plugin loading

+ (instancetype)defaultParser
{
    static VXPlaylistParser *_parser;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _parser = [[VXPlaylistParser alloc] init];
        [_parser loadPlugins];
    });
    
    return _parser;
}

- (void)loadPlugins
{
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    
    NSString *plugInsPath = [[NSBundle mainBundle] builtInPlugInsPath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:plugInsPath];
    NSString *file;
    while (file = [enumerator nextObject]) {
        // ignore any files that are not ".plplug"
        if(![file.pathExtension isEqualToString:VXPlaylistPluginExtension]) continue;
        
        NSBundle *pluginBundle = [NSBundle bundleWithPath:[NSString pathWithComponents:@[plugInsPath,file]]];

        if(![pluginBundle load]) {
            NSLog(@"[VXPlaylistParser] Unable to load plugin %@", file);
            continue;
        }
        
        Class pluginClass = [pluginBundle principalClass];
        
        // add to our plugins array
        [classes addObject:pluginClass];
    }
    
    _pluginClasses = [classes copy];
    
    NSLog(@"[VXPlaylistParser] %lu playlist parser(s) loaded.", _pluginClasses.count);
}

#pragma mark PlugIn Interface

+ (BOOL)canWorkWithData:(NSData *)data
{
    return [[VXPlaylistParser defaultParser] canWorkWithData:data];
}

+ (void)parsePlaylistWithData:(NSData *)data completionHandler:(VXPlaylistParserCompletionHandler)callback
{
    [[[VXPlaylistParser defaultParser] parserClassForData:data] parsePlaylistWithData:data completionHandler:callback];
}

#pragma mark Private Interface

/**
 Returns YES if one of the loaded plugins can work with the data provided
 */
- (BOOL)canWorkWithData:(NSData *)data
{
    for (Class parserClass in _pluginClasses) {
        if ([parserClass canWorkWithData:data]) return YES;
    }
    return NO;
}

- (Class)parserClassForData:(NSData *)data
{
    for (Class parserClass in _pluginClasses) {
        if ([parserClass canWorkWithData:data]) return parserClass;
    }
    
    return nil;
}

@end
