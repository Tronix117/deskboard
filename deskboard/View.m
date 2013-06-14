//
//  ViewController.m
//  Deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import "View.h"

@interface View ()

@end

@implementation View

/*- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}*/

- (void)drawRect:(NSRect)pRect {
	[[NSColor clearColor] set];
	NSRectFill( pRect );
    
	NSMutableDictionary *zDictAttributes = [[NSMutableDictionary alloc] init];
	[zDictAttributes setObject:[NSFont fontWithName:@"Helvetica" size:60]
                        forKey:NSFontAttributeName];
	[zDictAttributes setObject:[NSColor yellowColor]
                        forKey:NSForegroundColorAttributeName];
	
	NSPoint	zPoint;
	zPoint.x	= 10.0;
	zPoint.y	= 10.0;
	
	NSString *zString	= @"Hello word";
   	
	[zString drawAtPoint:zPoint withAttributes:zDictAttributes];
}

@end
