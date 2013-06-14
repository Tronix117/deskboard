//
//  AppDelegate.h
//  deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
  NSWindow *window;  
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

@end
