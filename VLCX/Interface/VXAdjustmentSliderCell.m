//
//  VXAdjustmentSliderCell.m
//  VLCX
//
//  Created by Guilherme Rambo on 19/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXAdjustmentSliderCell.h"

CGFloat const VXAdjustmentSliderKnobWidth = 3.0;
CGFloat const VXAdjustmentSliderKnobHeight = 17.0;
CGFloat const VXAdjustmentSliderKnobColor[4] = {0, 0.25, 0.8, 1};
CGFloat const VXAdjustmentSliderTrackBackgroundColor[2] = {0.15, 1.0};
CGFloat const VXAdjustmentSliderTrackFillColor[2] = {0.4, 1.0};

@implementation VXAdjustmentSliderCell

- (void)drawKnob:(NSRect)knobRect
{
    [[NSColor colorWithCalibratedRed:VXAdjustmentSliderKnobColor[0]
                               green:VXAdjustmentSliderKnobColor[1]
                                blue:VXAdjustmentSliderKnobColor[2]
                               alpha:VXAdjustmentSliderKnobColor[3]] setFill];
    NSRectFill(knobRect);
}

- (void)drawBarInside:(NSRect)cellFrame flipped:(BOOL)flipped
{
    NSRect barRect = cellFrame;
    barRect.size.height = VXAdjustmentSliderKnobHeight;
    
    NSRect fillRect = barRect;
    NSRect knobRect = [self knobRectFlipped:flipped];
    fillRect.size.width = knobRect.origin.x;
    
    NSBezierPath *barPath = [NSBezierPath bezierPathWithRect:barRect];
    [[NSColor colorWithCalibratedWhite:VXAdjustmentSliderTrackBackgroundColor[0]
                                 alpha:VXAdjustmentSliderTrackBackgroundColor[1]] setFill];
    [barPath fill];
    
    NSBezierPath *fillPath = [NSBezierPath bezierPathWithRect:fillRect];
    [[NSColor colorWithCalibratedWhite:VXAdjustmentSliderTrackFillColor[0]
                                 alpha:VXAdjustmentSliderTrackFillColor[1]] setFill];
    [fillPath fill];
}

- (NSRect)barRectFlipped:(BOOL)flipped
{
    return NSMakeRect(0, 0, NSWidth(self.controlView.frame), NSHeight(self.controlView.frame));
}

- (NSRect)knobRectFlipped:(BOOL)flipped{
    
    CGFloat value = (self.doubleValue - self.minValue) / (self.maxValue - self.minValue);

    NSRect newRect = NSMakeRect(0, 0, 0, 0);
    newRect.size.width = VXAdjustmentSliderKnobWidth;
    newRect.size.height = VXAdjustmentSliderKnobHeight;
    newRect.origin.x = value * (NSWidth(self.controlView.frame) - VXAdjustmentSliderKnobWidth);
    
    return newRect;
}

@end
