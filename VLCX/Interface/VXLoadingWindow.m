//
//  VXLoadingWindow.m
//  VLCX
//
//  Created by Guilherme Rambo on 20/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXLoadingWindow.h"

CGFloat const VXLoadingWindowWidth = 200;
CGFloat const VXLoadingWindowHeight = 150;
NSString *VXLoadingWindowTitleFontName = @"HelveticaNeue-Light";
CGFloat const VXLoadingWindowTitleFontSize = 16.0;

@interface VXLoadingWindow ()

@property (strong) NSTextField *titleLabel;
@property (strong) NSVisualEffectView *backgroundView;
@property (strong) NSProgressIndicator *progressIndicator;

@end

@implementation VXLoadingWindow

- (instancetype)initWithTitle:(NSString *)title
{
    if (!(self = [super initWithContentRect:NSMakeRect(0, 0, VXLoadingWindowWidth, VXLoadingWindowHeight) styleMask:NSTitledWindowMask backing:NSBackingStoreRetained defer:NO])) return nil;
    
    self.title = title;
    self.styleMask |= NSFullSizeContentViewWindowMask;
    self.titleVisibility = NSWindowTitleHidden;
    self.titlebarAppearsTransparent = YES;
    
    self.collectionBehavior = NSWindowCollectionBehaviorDefault|NSWindowCollectionBehaviorTransient|NSWindowCollectionBehaviorIgnoresCycle;
    self.movableByWindowBackground = YES;
    
    [self setupBackground];
    [self setupTitle];
    [self setupProgressIndicator];
    
    return self;
}

- (void)setupBackground
{
    self.backgroundView = [[NSVisualEffectView alloc] init];
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundView.state = NSVisualEffectStateActive;
    self.backgroundView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    [self.contentView addSubview:self.backgroundView];
    
    NSDictionary *views = @{@"backgroundView": self.backgroundView,
                            @"superview": self.contentView};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[backgroundView]-(0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[backgroundView]-(0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
}

- (void)setupTitle
{
    self.titleLabel = [[NSTextField alloc] init];
    self.titleLabel.bordered = NO;
    self.titleLabel.drawsBackground = NO;
    self.titleLabel.editable = NO;
    self.titleLabel.selectable = NO;
    self.titleLabel.stringValue = self.title;
    self.titleLabel.textColor = [NSColor secondaryLabelColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [NSFont fontWithName:VXLoadingWindowTitleFontName size:VXLoadingWindowTitleFontSize];
    self.titleLabel.alignment = NSCenterTextAlignment;
    
    [self.backgroundView addSubview:self.titleLabel];
    
    NSDictionary *views = @{@"titleLabel": self.titleLabel,
                            @"superview": self.backgroundView};
    
    [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[titleLabel]-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views]];
    
    [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views]];
}

- (void)setupProgressIndicator
{
    self.progressIndicator = [[NSProgressIndicator alloc] init];
    self.progressIndicator.controlSize = NSRegularControlSize;
    self.progressIndicator.style = NSProgressIndicatorSpinningStyle;
    self.progressIndicator.indeterminate = YES;
    self.progressIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundView addSubview:self.progressIndicator];
    
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressIndicator
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.backgroundView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressIndicator
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.backgroundView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:10]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressIndicator
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:32]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressIndicator
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:32]];
    
    [self.progressIndicator startAnimation:nil];
}

- (void)makeKeyAndOrderFront:(id)sender
{
    [self center];
    self.alphaValue = 0;
    [super makeKeyAndOrderFront:sender];
    self.animator.alphaValue = 1;
}

//- (void)close
//{
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        self.animator.alphaValue = 0;
//    } completionHandler:^{
//        [self.progressIndicator stopAnimation:nil];
//        
//        [super close];
//    }];
//}

@end
