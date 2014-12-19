//
//  VXVideoAdjustmentsController.m
//  VLCX
//
//  Created by Guilherme Rambo on 19/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXVideoAdjustmentsController.h"

@interface VXVideoAdjustmentsController ()

@property (weak) IBOutlet NSSlider *brightnessSlider;
@property (weak) IBOutlet NSSlider *contrastSlider;
@property (weak) IBOutlet NSSlider *gammaSlider;
@property (weak) IBOutlet NSSlider *hueSlider;
@property (weak) IBOutlet NSSlider *saturationSlider;
@property (weak) IBOutlet NSLayoutConstraint *rightConstraint;

@end

@implementation VXVideoAdjustmentsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hidePanelAnimated:NO];
}

#pragma mark Adjustments Panel Visibility

- (void)togglePanelVisibility
{
    if (self.isPanelVisible) {
        [self hidePanelAnimated:YES];
    } else {
        [self showPanelAnimated:YES];
    }
}

- (void)showPanelAnimated:(BOOL)animated
{
    self.panelVisible = YES;
    
    if (animated) {
        self.view.hidden = NO;
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            self.rightConstraint.animator.constant = 0;
        } completionHandler:^{
            [self viewDidAppear];
        }];
    } else {
        self.rightConstraint.animator.constant = 0;
        self.view.hidden = NO;
    }
}

- (void)hidePanelAnimated:(BOOL)animated
{
    self.panelVisible = NO;
    
    if (animated) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            self.rightConstraint.animator.constant = NSWidth(self.view.frame)*-1;
        } completionHandler:^{
            self.view.hidden = YES;
        }];
    } else {
        self.rightConstraint.animator.constant = NSWidth(self.view.frame)*-1;
        self.view.hidden = YES;
    }
}

#pragma mark Video Adjustment Actions

- (void)updateAdjustments
{
    self.player.adjustFilterEnabled = NO;
    
    self.player.brightness = self.brightnessSlider.doubleValue;
    self.player.contrast = self.contrastSlider.doubleValue;
    self.player.gamma = self.gammaSlider.doubleValue;
    self.player.hue = self.hueSlider.intValue;
    self.player.saturation = self.saturationSlider.doubleValue;
    
    self.player.adjustFilterEnabled = YES;
}

- (IBAction)brightnessSliderAction:(id)sender {
    [self updateAdjustments];
}

- (IBAction)contrastSliderAction:(id)sender {
    [self updateAdjustments];
}

- (IBAction)gammaSliderAction:(id)sender {
    [self updateAdjustments];
}

- (IBAction)hueSliderAction:(id)sender {
    [self updateAdjustments];
}

- (IBAction)saturationSliderAction:(id)sender {
    [self updateAdjustments];
}

@end
