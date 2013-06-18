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

- (void)loadView {
    [self viewWillLoad];
    
    self.view = [[NSView alloc] initWithFrame:[[NSScreen mainScreen] frame]];
    
    NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:[NSScreen mainScreen]];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
    
    self.view.wantsLayer = YES;
    self.view.layer.contents = image;
    
    [self viewDidLoad];
}

-(void)buttonPressed: (NSObject *) sender {
    NSLog(@"Button pressed!");
    [self.view setNeedsDisplay:YES];
}

-(void)viewWillLoad {
    launchpadHelper = [[LaunchpadDatabaseHelper alloc] init];
}

-(void)viewDidLoad {
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    
    documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, [[launchpadHelper getPages] count] * screenFrame.size.width, screenFrame.size.height)];
        
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame: [[NSScreen mainScreen] frame]];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setDrawsBackground:NO];
    [scrollView setDocumentView: documentView];
    [self.view addSubview:scrollView];
    
    [self documentViewDidLoad];
}

-(void)documentViewDidLoad {
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    int marginLeft = screenFrame.size.width * 0.08;
    int marginRight = marginLeft;
    int marginTop = screenFrame.size.height * 0.05;
    int marginBottom = screenFrame.size.height * 0.10;
    
    NSArray *pages = [launchpadHelper getPages];
    
    int c = (int)[pages count];
    for (int i = 0; i < c; i++) {
        NSDictionary *page = pages[i];
        
        NSView *pageView = [[NSView alloc] initWithFrame:NSMakeRect(i * screenFrame.size.width + marginLeft, marginBottom, screenFrame.size.width - marginLeft -marginRight, screenFrame.size.height - marginBottom - marginTop)];

        NSArray *items = [launchpadHelper getPageContentForPageId:[[page objectForKey:@"rowid"] intValue]];

        int j = 0;
        for (NSDictionary *item in items) {
            [self addIconFromItem: item withIndex: j toView: pageView];
            j++;
        }
        
        [documentView addSubview: pageView];
    }
}

-(NSView *)addIconFromItem: (NSDictionary *) item withIndex: (int) i toView: (NSView *)pageView{
    int textViewHeight = 20;
    
    int width = pageView.frame.size.width / (1.30 * GRID_APP_HORIZONTALY - 0.30);
    int height = (pageView.frame.size.height - GRID_APP_VERTICALY * textViewHeight) / (GRID_APP_VERTICALY + 0.30 * (GRID_APP_VERTICALY - 1));
    int horizontalSpacing = width * 0.30 - textViewHeight;
    int verticalSpacing = height * 0.30;
    
    int left = 1.5 * horizontalSpacing + (width + horizontalSpacing) * (i % GRID_APP_HORIZONTALY);
    int bottom = pageView.frame.size.height - ((height + verticalSpacing) * (i / GRID_APP_HORIZONTALY +1));
    
    NSView *appView = [[NSView alloc] initWithFrame:NSMakeRect(left, bottom, width, height)];
    
    int itemType = [[item objectForKey:@"type"] intValue];
    if (itemType == LAUNCHPAD_TYPE_APP) {
        NSDictionary *app = [launchpadHelper getAppFromItem:item];
        NSLog(@"-- App.title: %@", [app objectForKey:@"title"]);
        
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, textViewHeight, width, height - textViewHeight)];
        NSImage *image = [[NSImage alloc] initWithData:[launchpadHelper getImageDataFromItem: item]];
        [imageView setImage: image];
        
        NSTextView *titleView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, width, textViewHeight)];
        [titleView setString:[app objectForKey:@"title"]];
        [titleView setAlignment:NSCenterTextAlignment];
        [titleView setBackgroundColor:[NSColor clearColor]];
        [titleView setTextColor:[NSColor whiteColor]];
        [titleView setFont:[NSFont fontWithName:@"Helvetica Neue Bold" size:13]];
        
        NSShadow *textShadow = [[NSShadow alloc] init];
        [textShadow setShadowColor:[NSColor blackColor]];
        [textShadow setShadowOffset:NSMakeSize(-0.7, 0.7)];
        [textShadow setShadowBlurRadius:1];
        [titleView setShadow:textShadow];
        
        [appView addSubview:titleView];
        [appView addSubview: imageView];
        
    } else if(itemType == LAUNCHPAD_TYPE_GROUP) {
        NSDictionary *group = [launchpadHelper getGroupFromItem:item];
        NSLog(@"-- Group.title: %@", [group objectForKey:@"title"]);
    }
    
    [pageView addSubview:appView];
    
    return appView;
}

@end