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

-(void)viewWillLoad {
    launchpadHelper = [[LaunchpadDatabaseHelper alloc] init];
}

-(void)viewDidLoad {
    screenFrame = [[NSScreen mainScreen] frame];
    
    documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, [[launchpadHelper getPages] count] * screenFrame.size.width, screenFrame.size.height)];
    
    currentPage = 0;
    
    scrollView = [[ScrollView alloc] initWithFrame: [[NSScreen mainScreen] frame]];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setRulersVisible:NO];
    [scrollView setDrawsBackground:NO];
    [scrollView setDocumentView: documentView];
    //[[scrollView contentView] setPostsBoundsChangedNotifications:YES];
    [scrollView setDelegate:self];
    [scrollView setDisableSrollWheel:YES];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[scrollView contentView]];
    isScrolling = NO;
    
    clipView = [scrollView contentView];
    
    [self.view addSubview:scrollView];
    
    [self documentViewDidLoad];
}

-(void)documentViewDidLoad {
    int marginLeft = screenFrame.size.width * 0.08;
    int marginRight = marginLeft;
    int marginTop = screenFrame.size.height * 0.05;
    int marginBottom = screenFrame.size.height * 0.10;
    
    NSArray *pages = [launchpadHelper getPages];
    
    pagingView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, screenFrame.size.height * 0.08, screenFrame.size.width, 34)];
    [pagingView setAlignment:NSCenterTextAlignment];
    [pagingView setBackgroundColor:[NSColor clearColor]];
    [pagingView setFont:[NSFont fontWithName:@"Arial" size:32]];
    NSString *pagingString = @"";
    
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
        
        pagingString = [pagingString stringByAppendingString:@"• "];
        
        [documentView addSubview: pageView];
    }
    [pagingView setString: pagingString];
    
    for (int i = 0; i < c; i++){
        [pagingView setFont:[NSFont fontWithName:@"Arial" size:14] range:NSMakeRange(i * 2 + 1, 1)];
    }
    
    [self.view addSubview: pagingView];
    [self updatePaging];
}

-(void)updatePaging{
    [pagingView setTextColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.3]];
    [pagingView setTextColor: [NSColor whiteColor] range: NSMakeRange (currentPage * 2, 1)];
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
    
    NSButton *clickArea = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, width, height)];
    [clickArea setTag:[[item objectForKey:@"rowid"] intValue]];
    [clickArea setTarget:self];
    [clickArea setTransparent:YES];
    [clickArea setBordered:NO];
    
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
        [appView addSubview:imageView];
        
        [clickArea setAction:@selector(appClickAction:)];
        
    } else if(itemType == LAUNCHPAD_TYPE_GROUP) {
        NSDictionary *group = [launchpadHelper getGroupFromItem:item];
        NSLog(@"-- Group.title: %@", [group objectForKey:@"title"]);
    }
    
    [appView addSubview:clickArea];
    [pageView addSubview:appView];
    
    return appView;
}

-(void)scrollWheel:(NSEvent *)theEvent{
    if (isScrolling)
        return;
    
    int pageDirection = [self getPageDirection];
    
    if (pageDirection!=0){
        [self scrollToPage: currentPage + pageDirection];
    } else {
        NSPoint origin = [clipView bounds].origin;
        origin.x -= theEvent.scrollingDeltaX * 0.5;
        [clipView setBoundsOrigin:origin];
    }
}

-(void)scrollViewDidEndScrolling{
    [self scrollToPage: currentPage + [self getPageDirection]];
}

-(int)getPageDirection{
    int currentPos = [clipView bounds].origin.x;
    int originPos = currentPage * screenFrame.size.width;
    int sensibility = screenFrame.size.width * 0.10;
    
    if (currentPos - sensibility > originPos)
        return 1;
    else if (currentPos + sensibility < originPos)
        return -1;
    else
        return 0;
}


-(void)scrollToPage: (int) page{
    if(isScrolling)
        return;
        
    isScrolling = YES;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        isScrolling = NO;
    }];
    NSPoint newOrigin = [clipView bounds].origin;
    newOrigin.x = page * screenFrame.size.width;
    [[clipView animator] setBoundsOrigin:newOrigin];
    [NSAnimationContext endGrouping];
    
    currentPage = page;
    [self updatePaging];
}

-(void)appClickAction:(NSButton *) sender{
    //[self scrollToPage:1];
    //NSRect screenFrame = [[NSScreen mainScreen] frame];
    [NSAnimationContext beginGrouping];
    NSPoint newOrigin = [clipView bounds].origin;
    newOrigin.x = 1920;
    [[clipView animator] setBoundsOrigin:newOrigin];
    [NSAnimationContext endGrouping];
    //NSDictionary *app = [launchpadHelper getAppWithItemId:(int)sender.tag];
    //[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:[app objectForKey:@"bundleid"] options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:nil];
}

@end