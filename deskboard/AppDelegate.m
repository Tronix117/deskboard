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
    [window setLevel:kCGDesktopWindowLevel];
    [window setCollectionBehavior: NSWindowCollectionBehaviorStationary | NSWindowCollectionBehaviorCanJoinAllSpaces]; // NSWindowCollectionBehaviorFullScreenPrimary
    [window setHidesOnDeactivate: NO];
    
    [window setFrame:[[NSScreen mainScreen] frame] display:YES];
    [window setIgnoresMouseEvents:NO];
     self.viewController = [[ViewController alloc] init];
    [window setContentView: [self.viewController view]];
    [self.viewController setWindow:window];
    [window makeKeyAndOrderFront:NSApp];
    
   /* [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
           selector:@selector(activeSpaceDidChange:)
               name:NSWorkspaceActiveSpaceDidChangeNotification
             object:nil];
    */
    //[self enableDesktop:NO];
}

-(void) enableDesktop: (BOOL) enable{
    NSString * writeOrDelete;
    
    if (enable)
        writeOrDelete = @"delete";
    else
        writeOrDelete = @"write";
        
    NSArray *arguments = [NSArray arrayWithObjects: writeOrDelete, @"com.apple.finder", @"CreateDesktop", "-bool", "FALSE", nil];
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/defaults" arguments:arguments] waitUntilExit];
    
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall" arguments:[NSArray arrayWithObjects:@"Finder", nil]] waitUntilExit];
}

/*- (void) activeSpaceDidChange:(NSNotification*)aNotification
{
    [window orderFront:self];
}*/

@end
