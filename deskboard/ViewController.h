//
//  ViewController.h
//  Deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LaunchpadDatabaseHelper.h"
#import "ScrollView.h"
#import "GroupView.h"
#import <QuartzCore/QuartzCore.h>
#import "VDKQueue.h"

#define GRID_APP_HORIZONTALY 7
#define GRID_APP_VERTICALY 5

@interface ViewController : NSViewController{
    int currentPage;
    LaunchpadDatabaseHelper *launchpadHelper;
    NSView * documentView;
    ScrollView * scrollView;
    NSClipView* clipView;
    BOOL isScrolling;
    NSRect screenFrame;
    NSTextView * pagingView;
}

-(void)appClickAction:(id) sender;

@end