//
//  VXURLMediaDetector.m
//  VLCX
//
//  Created by Guilherme Rambo on 20/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXURLMediaDetector.h"
#import "VXAudioDocument.h"
#import "VXVideoDocument.h"

NSString *const VLCXMediaDetectorErrorDomain = @"VLCXMediaDetectorErrorDomain";

@import VLCKit;

@interface VXURLMediaDetector () <VLCMediaDelegate>

@property (copy) NSURL *URL;
@property (copy) VXURLMediaDetectorCompletionHandler completionHandler;
@property (strong) VLCMedia *media;
@property (strong) VLCMediaPlayer *player;

@end

@implementation VXURLMediaDetector

- (instancetype)initWithURL:(NSURL *)anURL completionHandler:(VXURLMediaDetectorCompletionHandler)callback
{
    if (!(self = [super init])) return nil;
    
    self.URL = anURL;
    self.completionHandler = callback;
    
    return self;
}

- (void)run
{
    self.media = [VLCMedia mediaWithURL:self.URL];
    self.media.delegate = self;
    self.player = [[VLCMediaPlayer alloc] init];
    self.player.media = self.media;
    self.player.audio.volume = 0;
    [self.player play];
}

#pragma mark Private methods

- (void)mediaDidFinishParsing:(VLCMedia *)aMedia
{
    if (aMedia.state == VLCMediaStateError) {
        [self callCompletionHandlerOnMainThreadWithDocumentClass:nil error:[self mediaDetectorErrorWithCode:1 message:NSLocalizedString(@"Unable to open URL", @"Unable to open URL")]];
    } else {
        if ([self mediaHasVideoTracks]) {
            [self callCompletionHandlerOnMainThreadWithDocumentClass:[VXVideoDocument class] error:nil];
        } else {
            [self callCompletionHandlerOnMainThreadWithDocumentClass:[VXAudioDocument class] error:nil];
        }
    }
}

- (BOOL)mediaHasVideoTracks
{
    for (NSDictionary *track in self.player.media.tracksInformation) {
        if ([track[@"type"] isEqualToString:@"video"]) return YES;
    }
    
    return NO;
}

- (NSError *)mediaDetectorErrorWithCode:(NSInteger)code message:(NSString *)message
{
    return [NSError errorWithDomain:VLCXMediaDetectorErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: message}];
}

- (void)callCompletionHandlerOnMainThreadWithDocumentClass:(Class)docClass error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionHandler(docClass, error);
    });
    [self.player stop];
}

- (void)dealloc
{
    [self.player stop];
}

@end
