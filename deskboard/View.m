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
    NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:[NSScreen mainScreen]];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
    self.wantsLayer = YES;
    self.layer.contents = image;
	NSRectFill( pRect );
}

-(void)viewDidLoad {
    NSButton *myButton = [[NSButton alloc] initWithFrame:NSMakeRect(100, 100, 130, 40)];
    
    [myButton setTitle: @"Button title!"];
    [myButton setButtonType:NSMomentaryLightButton];
    [myButton setBezelStyle:NSRoundedBezelStyle];
    
    [myButton setTarget: self.viewController];
    [myButton setAction:@selector(buttonPressed:)];
    
    [self addSubview: myButton];
}
@end
