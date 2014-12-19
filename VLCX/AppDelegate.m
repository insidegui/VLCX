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

// you can safely comment out the line below
#import "Config.h"

#ifdef CRASHLYTICS_API_KEY
#import <Crashlytics/Crashlytics.h>
#endif

@interface AppDelegate ()
@end

@implementation AppDelegate

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    // register a callback to handle our URL schemes
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(openURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    return self;
}

// this is called when a user drags an internet URL to the dock icon, for instance
- (void)openURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    // extract the actual URL from the event descriptor
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];

    // determine the class of document to create based on the document's type
    Class docClass = [NSDocumentController documentClassForExtension:url.pathExtension];
    
    // instantiate a new document to represent the URL
    VXMediaDocument *doc = [[docClass alloc] initWithType:[NSDocumentController documentTypeNameForExtension:url.pathExtension] internetURL:url];
    doc.internetURL = url;
    
    // add the document to our document controller
    [[NSDocumentController sharedDocumentController] addDocument:doc];
    
    // initialize the document and show it's window
    [doc makeWindowControllers];
    [doc showWindows];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    #ifdef CRASHLYTICS_API_KEY
    [Crashlytics startWithAPIKey:CRASHLYTICS_API_KEY];
    #endif
}

@end
