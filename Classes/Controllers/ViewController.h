//
//  ViewController.h
//  Deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LaunchpadDatabase.h"
#import "ScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "VDKQueue.h"

#define GRID_APP_HORIZONTALY 7
#define GRID_APP_VERTICALY 5
#define GRID_APP_SPACING_SCALE 0.3
#define GRID_APP_TITLE_FONT_SIZE 13
#define GRID_GROUP_BORDER_SIZE 6.0
#define GRID_GROUP_BORDER_RADIUS 20.0

@interface ViewController : NSViewController{
    int currentPage;
    LaunchpadDatabase *launchpadHelper;
    NSView * documentView;
    ScrollView * scrollView;
    //NSImageView *backgroundView;
    NSClipView* clipView;
    BOOL isScrolling;
    NSRect screenFrame;
    NSTextView * pagingView;
    //NSSearchField * searchField;
}

@property(assign) NSWindow * window;

-(void)appClickAction:(id) sender;

@end