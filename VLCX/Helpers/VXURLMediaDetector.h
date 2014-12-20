//
//  VXURLMediaDetector.h
//  VLCX
//
//  Created by Guilherme Rambo on 20/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VXURLMediaDetectorCompletionHandler)(Class documentClass, NSError *error);

@interface VXURLMediaDetector : NSObject

- (instancetype)initWithURL:(NSURL *)anURL completionHandler:(VXURLMediaDetectorCompletionHandler)callback;
- (void)run;

@end
