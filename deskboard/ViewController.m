//
//  ViewController.m
//  Deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)init
{
    self = [super init];
    if (self) {
        LaunchpadDatabaseHelper *launchpadHelper = [[LaunchpadDatabaseHelper alloc] init];
        NSLog(@"%@", [launchpadHelper getApps]);
    }
    
    return self;
}

-(void)loadView {
    View *view = [[View alloc] initWithFrame:CGRectMake(0, 0, 3000, 3000)];
    view.viewController = self;
    self.view = view;
    [view viewDidLoad]; // dirty but button doesn't seems to work otherwise...
}

-(void)buttonPressed: (NSObject *) sender {
    NSLog(@"Button pressed!");
}
@end
