//
//  AppDelegate.m
//  deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
    
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    window  = [[NSWindow alloc] initWithContentRect: [[NSScreen mainScreen] frame]
                                          styleMask: NSBorderlessWindowMask //NSFullScreenWindowMask|
                                            backing: NSBackingStoreBuffered
                                              defer: NO];
    //[window setOpaque:NO];
    //[window setLevel:kCGDockWindowLevel - 1];

    [window setLevel:kCGDesktopWindowLevel + 20];
    [window setCollectionBehavior: NSWindowCollectionBehaviorFullScreenPrimary | NSWindowCollectionBehaviorCanJoinAllSpaces];
    
    [window setFrame:[[NSScreen mainScreen] frame] display:YES];
    [window setIgnoresMouseEvents:NO];
     self.viewController = [[ViewController alloc] init];
    [window setContentView: [self.viewController view]];
    [window makeKeyAndOrderFront:NSApp];
}

@end
