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
    
    [self.view setWantsLayer:YES];
    [self.view.layer setContents:image];
    
    [self viewDidLoad];
}

-(void)viewWillLoad {
    launchpadHelper = [[LaunchpadDatabaseHelper alloc] init];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(refreshView) name:@"VDKQueueFileWrittenToNotification" object:nil];
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

-(void)refreshView {
    [documentView removeFromSuperview];
    [self viewDidLoad];
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
    NSView *itemView;
    
    NSButton *clickArea = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, width, height)];
    [clickArea setTag:[[item objectForKey:@"rowid"] intValue]];
    [clickArea setTarget:self];
    [clickArea setTransparent:YES];
    [clickArea setBordered:NO];
    
    NSTextView *titleView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, width, textViewHeight)];
    [titleView setAlignment:NSCenterTextAlignment];
    [titleView setBackgroundColor:[NSColor clearColor]];
    [titleView setTextColor:[NSColor whiteColor]];
    [titleView setFont:[NSFont fontWithName:@"Helvetica Neue Bold" size:13]];
    
    NSShadow *textShadow = [[NSShadow alloc] init];
    [textShadow setShadowColor:[NSColor blackColor]];
    [textShadow setShadowOffset:NSMakeSize(-0.7, 0.7)];
    [textShadow setShadowBlurRadius:1];
    [titleView setShadow:textShadow];
    
    int itemType = [[item objectForKey:@"type"] intValue];
    if (itemType == LAUNCHPAD_TYPE_APP) {
        NSDictionary *app = [launchpadHelper getAppFromItem:item];
        [titleView setString: [app objectForKey:@"title"]];
        
        itemView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, textViewHeight, width, height - textViewHeight)];
        NSImage *image = [[NSImage alloc] initWithData:[launchpadHelper getImageDataFromItem: item]];
        [(NSImageView *)itemView setImage: image];
        
        [clickArea setAction:@selector(appClickAction:)];
        
    } else if(itemType == LAUNCHPAD_TYPE_GROUP) {
        NSDictionary *group = [launchpadHelper getGroupFromItem:item];
        [titleView setString: [group objectForKey:@"title"]];
        
        NSArray *insideItems = [launchpadHelper getContentFromGroup:group];
        
        NSImage *background = [self generateGroupViewBackgroundImage];
        
        int borderWidth = 6.0f;
        int groupViewSideSize = (height - textViewHeight) * 0.9; // the scale is to let some space for the shadow
        int groupViewBottom = ((height - textViewHeight) - groupViewSideSize) / 2 + textViewHeight;
        int groupViewLeft = (width - groupViewSideSize)/ 2;
        
        NSCustomImageRep *gradientImageRep = [[NSCustomImageRep alloc] initWithSize:NSMakeSize(groupViewSideSize, groupViewSideSize) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
            NSGradient* aGradient = [[NSGradient alloc]
                                     initWithStartingColor:[NSColor colorWithCalibratedWhite:0.7 alpha:1.0]
                                     endingColor:[NSColor colorWithCalibratedWhite:0.5 alpha:1.0]];
            [aGradient drawInRect:dstRect angle:270];
            return YES;
        }];
        NSImage *gradientImage = [[NSImage alloc] initWithSize:[gradientImageRep size]];
        [gradientImage addRepresentation: gradientImageRep];
        NSColor *borderColor = [NSColor colorWithPatternImage:gradientImage];
        
        itemView = [[NSView alloc] initWithFrame:NSMakeRect(groupViewLeft, groupViewBottom, groupViewSideSize, groupViewSideSize)];
        [itemView setWantsLayer:YES];
        
        [itemView.layer setBackgroundColor:[NSColor colorWithPatternImage: background].CGColor];
        [itemView.layer setCornerRadius:20.0];
        itemView.layer.borderColor = borderColor.CGColor;
        itemView.layer.borderWidth = borderWidth;
        
        NSShadow *boxShadow = [[NSShadow alloc] init];
        
        [boxShadow setShadowColor:[NSColor blackColor]];
        [boxShadow setShadowOffset:NSMakeSize(-0.3, -0.3)];
        [boxShadow setShadowBlurRadius:3];
        
        [itemView setShadow:boxShadow];
        
        
        int c = (int)[insideItems count];
        if (c > 9) // No more than 9 previews for a group
            c = 9;
        
        int imageSideSize = groupViewSideSize * 0.25;
        
        for (int i = 0; i < c; i++) {
            int imageViewLeft = groupViewSideSize * 0.12 + imageSideSize * 1.1 * (i % 3);
            int imageViewBottom = groupViewSideSize * 0.12 + imageSideSize * 1.1 * ((8 - i) / 3);
            
            NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(imageViewLeft, imageViewBottom, imageSideSize, imageSideSize)];
            NSImage *image = [[NSImage alloc] initWithData:[launchpadHelper getImageDataFromItem: [insideItems objectAtIndex:i]]];
            [imageView setImage: image];
            
            [itemView addSubview:imageView];
        }
        
    }
    
    [appView addSubview:titleView];
    [appView addSubview:itemView];
    [appView addSubview:clickArea];
    [pageView addSubview:appView];
    
    return appView;
}

- (NSImage *)generateGroupViewBackgroundImage
{
    //-- Initialisation
    
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"/System/Library/Frameworks/AppKit.framework/Versions/C/Resources/NSTexturedFullScreenBackgroundColor.png"]];
    NSSize size = [image size];
    NSImage *outputImage = [[NSImage alloc] initWithSize:size];
    
    CIImage *baseImage = [CIImage imageWithData:[image TIFFRepresentation]];
    CIImage *chainedOutputImage = baseImage;
    
    [outputImage lockFocus];
    
    //-- Adjusting Brightness
    
    CIFilter *brightnessFilter = [CIFilter filterWithName:@"CIColorControls"];
    [brightnessFilter setDefaults];
    [brightnessFilter setValue:baseImage forKey:kCIInputImageKey];
    
    [brightnessFilter setValue:[NSNumber numberWithDouble:0.06] forKey: kCIInputBrightnessKey];
    
    chainedOutputImage = [brightnessFilter valueForKey:kCIOutputImageKey];
    
    //-- Adjusting Scale
    
    CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [scaleFilter setDefaults];
    [scaleFilter setValue:chainedOutputImage forKey:kCIInputImageKey];
    
    [scaleFilter setValue:[NSNumber numberWithFloat:1.5] forKey:kCIInputScaleKey];
    
    chainedOutputImage = [scaleFilter valueForKey:kCIOutputImageKey];
    
    //-- Drawing
    
    [chainedOutputImage drawAtPoint:NSZeroPoint
                           fromRect: chainedOutputImage.extent
                          operation:NSCompositeCopy
                           fraction:1.0];
    
    [outputImage unlockFocus];
    
    return outputImage;
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
    NSDictionary *app = [launchpadHelper getAppWithItemId:(int)sender.tag];
    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:[app objectForKey:@"bundleid"] options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:nil];
}

@end