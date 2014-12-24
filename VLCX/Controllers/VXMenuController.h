//
//  VXMenuController.h
//  VLCX
//
//  Created by Guilherme Rambo on 17/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const kMainMenuAudioItemTag;
extern NSInteger const kMainMenuAudioTracksItemTag;
extern NSInteger const kMainMenuSubtitlesItemTag;

@import VLCKit;

@interface VXMenuController : NSObject

@property (nonatomic, weak) VLCMediaPlayer *player;

- (void)setupSubtitleTracksMenu;

@end
