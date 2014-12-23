//
//  VLCXParser.m
//  VLCX
//
//  Created by Guilherme Rambo on 22/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VLCXParser.h"

#define VLCXPlaylistHeader @"bplist00"

@implementation VLCXParser

+ (BOOL)canWorkWithData:(NSData *)data
{
    NSData *header = [data subdataWithRange:NSMakeRange(0, 8)];
    NSString *headerString = [[NSString alloc] initWithData:header encoding:NSUTF8StringEncoding];
    
    return [headerString isEqualToString:VLCXPlaylistHeader];
}

+ (void)parsePlaylistWithData:(NSData *)data completionHandler:(VXPlaylistParserCompletionHandler)callback
{
    callback([NSKeyedUnarchiver unarchiveObjectWithData:data], nil);
}

@end
