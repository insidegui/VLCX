//
//  M3UParser.m
//  VLCX
//
//  Created by Guilherme Rambo on 22/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "M3UParser.h"

@interface M3UParser ()

@property (strong) NSMutableArray *playlistItems;
@property (strong) NSData *playlistData;
@property (strong) NSString *playlistString;

@end

#define M3UHeader @"#EXTM3U"

@implementation M3UParser

#pragma mark PlugIn Interface

+ (BOOL)canWorkWithData:(NSData *)data
{
    NSData *header = [data subdataWithRange:NSMakeRange(0, 7)];
    NSString *headerString = [[NSString alloc] initWithData:header encoding:NSUTF8StringEncoding];
    
    return ([headerString isEqualToString:M3UHeader]);
}

+ (void)parsePlaylistWithData:(NSData *)data completionHandler:(VXPlaylistParserCompletionHandler)callback
{
    M3UParser *parser = [[M3UParser alloc] initWithPlaylistData:data];
    [parser parseWithCompletionHandler:callback];
}

#pragma mark Private stuff

- (instancetype)initWithPlaylistData:(NSData *)data
{
    if (!(self = [super init])) return nil;
    
    self.playlistData = data;
    
    return self;
}

- (void)parseWithCompletionHandler:(VXPlaylistParserCompletionHandler)callback
{
    self.playlistString = [[NSString alloc] initWithData:self.playlistData encoding:NSUTF8StringEncoding];
    
    NSArray *lines = [self.playlistString componentsSeparatedByString:@"\n"];
    if (lines.count < 2) return callback(nil, [self invalidPlaylistFileError]);
    
    self.playlistItems = [NSMutableArray new];
    NSMutableDictionary *currentItem = [NSMutableDictionary new];
    int currentLine = 1;
    for (NSString *line in lines) {
        if ([line isEqualTo:@""]) {
            NSLog(@"[M3UParser] Line #%d is empty", currentLine);
        } else if ([self string:line matchesRegularExpression:[self headerExpression]]) {
            NSLog(@"[M3UParser] Found header at line #%d", currentLine);
        } else if ([self string:line matchesRegularExpression:[self infoExpression]]) {
            NSArray *relevantInfo = [line componentsSeparatedByString:@":"];
            NSArray *info = [relevantInfo[1] componentsSeparatedByString:@","];
            currentItem[@"length"] = @([info[0] integerValue]);
            NSArray *titleArray = [info subarrayWithRange:NSMakeRange(1, info.count-1)];
            if (titleArray.count > 1) {
                currentItem[@"title"] = [titleArray componentsJoinedByString:@","];
            } else {
                currentItem[@"title"] = info[1];
            }
        } else if ([self string:line matchesRegularExpression:[self pathExpression]]) {
            currentItem[@"path"] = line;
            [self.playlistItems addObject:[currentItem copy]];
        } else {
            NSLog(@"[M3UParser] Line #%d is invalid!", currentLine);
            
            callback(nil, [self parsingErrorWithLocalizedMessage:[NSString stringWithFormat:NSLocalizedString(@"Line #%d is invalid!", @"Line #%d is invalid!"), currentLine]]);
            
            return;
        }
        currentLine++;
    }
    
    callback([self.playlistItems copy], nil);
}

- (NSRegularExpression *)headerExpression
{
    return [NSRegularExpression regularExpressionWithPattern:M3UHeader
                                                     options:NSRegularExpressionDotMatchesLineSeparators
                                                       error:nil];
}

- (NSRegularExpression *)infoExpression
{
    return [NSRegularExpression regularExpressionWithPattern:@"(#EXTINF\\:)([0-9]+)(\\,)(.*)"
                                                     options:NSRegularExpressionDotMatchesLineSeparators
                                                       error:nil];
}

- (NSRegularExpression *)pathExpression
{
    return [NSRegularExpression regularExpressionWithPattern:@"(\\/+)"
                                                     options:NSRegularExpressionDotMatchesLineSeparators
                                                       error:nil];
}

- (BOOL)string:(NSString *)str matchesRegularExpression:(NSRegularExpression *)exp
{
    return [exp numberOfMatchesInString:str options:0 range:NSMakeRange(0, str.length)] > 0;
}

- (NSError *)parsingErrorWithLocalizedMessage:(NSString *)message
{
    return [NSError errorWithDomain:@"M3UParser" code:0 userInfo:@{NSLocalizedDescriptionKey: message}];
}

- (NSError *)invalidPlaylistFileError
{
    return [self parsingErrorWithLocalizedMessage:NSLocalizedString(@"Invalid playlist file", @"Invalid playlist file")];
}

@end
