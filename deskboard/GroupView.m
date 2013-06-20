//
//  GroupView.m
//  Deskboard
//
//  Created by Jeremy Trufier on 20/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import "GroupView.h"

@implementation GroupView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSBezierPath* roundRectPath = [NSBezierPath bezierPathWithRoundedRect: [self bounds] xRadius:10 yRadius:10];
    [roundRectPath addClip];
    NSRect drawingRect = [self bounds];
    NSRect shadowRect = NSMakeRect(drawingRect.origin.x, drawingRect.size.height, drawingRect.size.width, 6.0);
    NSGradient *shadowGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.43] endingColor:[NSColor whiteColor]];
    [shadowGradient drawInRect:shadowRect angle:90];
}

@end
