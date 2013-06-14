//
//  AppDelegate.m
//  deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    //[self.window setLevel:kCGDesktopWindowLevel];

}
    
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"launch");
    //NSView *view = [[View alloc] init];
    
    /*textField = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, 200, 17)];
    [textField setStringValue:@"My Label"];
    [textField setBezeled:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];*/
    //[[self.window contentView] addSubview:view];
    
    //self.window.backgroundColor = [NSColor whiteColor];
    
    //[self.window makeKeyAndOrderFront:nil];
    
    window  = [[NSWindow alloc] initWithContentRect: [[NSScreen mainScreen] frame]
                                          styleMask: NSFullScreenWindowMask|NSBorderlessWindowMask
                                            backing: NSBackingStoreBuffered
                                              defer: NO];
    [window setOpaque:NO];
    [window setLevel:kCGDesktopWindowLevel];
    [window setCollectionBehavior: NSWindowCollectionBehaviorFullScreenPrimary];
    [window makeKeyAndOrderFront:NSApp];
    
    ViewController *viewController = [[ViewController alloc] init];
    [window setContentView: [viewController view]];
}

@end
