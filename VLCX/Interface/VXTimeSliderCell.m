//
//  VXTimeSliderCell.m
//  VLCX
//
//  Created by Guilherme Rambo on 17/12/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "VXTimeSliderCell.h"

CGFloat const VXTimeSliderKnobWidth = 5;
CGFloat const VXTimeSliderKnobHeight = 15.0;
CGFloat const VXTimeSliderKnobRadius = 1.0;

@implementation VXTimeSliderCell

- (void)drawKnob:(NSRect)knobRect
{
    NSRect alignedKnobRect = knobRect;
    alignedKnobRect.origin.x += 1;
    alignedKnobRect.size.width -= 1;
    
    NSBezierPath *knob = [NSBezierPath  bezierPathWithRoundedRect:alignedKnobRect xRadius:VXTimeSliderKnobRadius yRadius:VXTimeSliderKnobRadius];
    [[NSColor secondaryLabelColor] setFill];
    [knob fill];
    
    NSRect leftSpacerRect = NSMakeRect(knobRect.origin.x, knobRect.origin.y, 1.0, NSHeight(knobRect));
    [[NSColor blackColor] setFill];
    NSRectFill(leftSpacerRect);
    
    NSRect rightSpacerRect = NSMakeRect(knobRect.origin.x+NSWidth(knobRect), knobRect.origin.y, 1.0, NSHeight(knobRect));
    [[NSColor blackColor] setFill];
    NSRectFill(rightSpacerRect);
}


- (NSRect)knobRectFlipped:(BOOL)flipped
{
    CGFloat value = (self.doubleValue - self.minValue) / (self.maxValue - self.minValue);
    
    NSRect defaultKnobRect = [super knobRectFlipped:flipped];
    NSRect actualKnobRect = NSMakeRect(0, 0, 0, 0);

    actualKnobRect.size.width = VXTimeSliderKnobWidth;
    actualKnobRect.size.height = VXTimeSliderKnobHeight;
    actualKnobRect.origin.x = round(value * (self.controlView.frame.size.width - VXTimeSliderKnobWidth));
    actualKnobRect.origin.y = round(NSHeight(defaultKnobRect)/2-NSHeight(actualKnobRect)/2);

    return actualKnobRect;
}

@end
