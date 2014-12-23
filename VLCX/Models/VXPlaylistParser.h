//
//  VXPlaylistParser.h
//  VLCX
//
//  Created by Guilherme Rambo on 22/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VXPlaylistPlugin.h"

/**
 @class VXPlaylistParser
 @abstract VXPlaylistParser is the bridge between VLCX and It's playlist parser plugins,
 It basically implements the same interface as the plugins,
 but actually finds the appropriate plugin and uses It to do the parsing.
 It is also responsible for loading the plugins and keeping a cache of them.
 */
@interface VXPlaylistParser : NSObject <VXPlaylistPlugin>

@end
