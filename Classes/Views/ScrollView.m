//
//  ScrollView.m
//  Deskboard
//
//  Created by Jeremy Trufier on 19/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import "ScrollView.h"

@implementation ScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initializing properties
        self.disableSrollWheel = NO;
    }
    
    return self;
}

// Overriding default scrollWhell
-(void) scrollWheel:(NSEvent *)theEvent{
    // Do default behavior if mouse scrolling is still enabled
    if (!self.disableSrollWheel)
        [super scrollWheel:theEvent];
    
    // Call the scrollWheel method of the delegate, so that some specific behaviors can be handled
    if([[self delegate] respondsToSelector:@selector(scrollWheel:)])
        [[self delegate] performSelector:@selector(scrollWheel:) withObject:theEvent];
    
    // Emulate a endScrolling by calling it 0.3sec after the scroll, by canceling this call every time, we ensure the scroll is finished when no scrolling has been made in less than 0.3sec. So we can call the endScrolling method
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrolling) withObject:nil afterDelay:0.3];
}

// Once the scrolling is finished
-(void)scrollViewDidEndScrolling
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if([[self delegate] respondsToSelector:@selector(scrollViewDidEndScrolling)])
        [[self delegate] performSelector:@selector(scrollViewDidEndScrolling)];
}

@end