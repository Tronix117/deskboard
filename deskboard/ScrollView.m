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
        self.disableSrollWheel = NO;
    }
    
    return self;
}

-(void) scrollWheel:(NSEvent *)theEvent{
    if (!self.disableSrollWheel)
        [super scrollWheel:theEvent];
    
    if([[self delegate] respondsToSelector:@selector(scrollWheel:)])
        [[self delegate] performSelector:@selector(scrollWheel:) withObject:theEvent];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrolling) withObject:nil afterDelay:0.3];
}

-(void)scrollViewDidEndScrolling
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if([[self delegate] respondsToSelector:@selector(scrollViewDidEndScrolling)])
        [[self delegate] performSelector:@selector(scrollViewDidEndScrolling)];
}

@end