//
//  AppDelegate.m
//  VLCX
//
//  Created by Guilherme Rambo on 15/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "AppDelegate.h"

#import "VXMediaDocument.h"
#import "NSDocumentController+VLCXAdditions.h"
#import "VXURLMediaDetector.h"
#import "VXLoadingWindow.h"
#import "VXRemoteController.h"

// you can safely comment out the line below
#import "Config.h"

#ifdef CRASHLYTICS_API_KEY
#import <Crashlytics/Crashlytics.h>
#endif

@interface AppDelegate ()

@property (strong) VXURLMediaDetector *mediaDetector;
@property (strong) VXRemoteController *remoteController;
@property (strong) NSMutableArray *loadingWindows;

@end

@implementation AppDelegate

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    // register a callback to handle our URL schemes
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(openURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    // this is to hold "loading" windows when opening URLs
    self.loadingWindows = [NSMutableArray new];
    
    return self;
}

// this is called when a user drags an internet URL to the dock icon, for instance
- (void)openURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    // extract the actual URL from the event descriptor
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];

    if (url.pathExtension && ![url.pathExtension isEqualToString:@""]) {
        // if we know the pathExtension, we just have to instantiate the appropriate document controller
        [self openUntitledDocumentWithClass:[NSDocumentController documentClassForExtension:url.pathExtension] URL:url];
    } else {
        // if we don't know the pathExtension, we need to detect the type based on the media
        [self detectTypeAndOpenDocumentForURL:url];
    }
}

- (void)openUntitledDocumentWithClass:(Class)docClass URL:(NSURL *)url
{
    // instantiate a new document to represent the URL
    VXMediaDocument *doc = [[docClass alloc] initWithType:[NSDocumentController documentTypeNameForExtension:url.pathExtension] internetURL:url];
    doc.internetURL = url;
    
    // add the document to our document controller
    [[NSDocumentController sharedDocumentController] addDocument:doc];
    
    // initialize the document and show it's window
    [doc makeWindowControllers];
    [doc showWindows];
}

- (void)detectTypeAndOpenDocumentForURL:(NSURL *)url
{
    VXLoadingWindow *loadingWindow = [[VXLoadingWindow alloc] initWithTitle:NSLocalizedString(@"Loading URL", @"Loading URL")];
    [self.loadingWindows addObject:loadingWindow];
    [loadingWindow makeKeyAndOrderFront:nil];
    
    self.mediaDetector = [[VXURLMediaDetector alloc] initWithURL:url completionHandler:^(Class documentClass, NSError *error) {
        if (error) {
            [[NSAlert alertWithError:error] runModal];
        } else {
            [self openUntitledDocumentWithClass:documentClass URL:url];
            self.mediaDetector = nil;
            
            [loadingWindow close];
        }
    }];
    
    [self.mediaDetector run];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    #ifdef CRASHLYTICS_API_KEY
    [Crashlytics startWithAPIKey:CRASHLYTICS_API_KEY];
    #endif
    
    self.remoteController = [VXRemoteController sharedController];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
    [self.remoteController appBecameActive];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self.remoteController appResignedActive];
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

@end
