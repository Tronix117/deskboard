//
//  ViewController.h
//  Deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LaunchpadDatabaseHelper.h"

#define GRID_APP_HORIZONTALY 7
#define GRID_APP_VERTICALY 5

@interface ViewController : NSViewController{
    int currentPage;
    LaunchpadDatabaseHelper *launchpadHelper;
    NSView * documentView;
}

-(void)buttonPressed:(NSObject *) sender;

@end