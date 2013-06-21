//
//  ViewController.m
//  Deskboard
//
//  Everything is in ViewController, this is a quick draft
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
    
    // This image will be the background, we take back the desktop background image
    NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:[NSScreen mainScreen]];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
    
    [self.view setWantsLayer:YES];
    [self.view.layer setContents:image];
    
    /* moving background - too slow
    screenFrame = [[NSScreen mainScreen] frame];
    NSRect bgImageFrame = screenFrame;
    
    float bgScaling = 1.5;
    bgImageFrame.size.width *= bgScaling;
    bgImageFrame.size.height *= bgScaling;
    bgImageFrame.origin.y = (screenFrame.size.height - bgImageFrame.size.height) / 2;
    
    backgroundView = [[NSImageView alloc] initWithFrame:bgImageFrame];
    [backgroundView setImage:image];
    [backgroundView setImageScaling:NSImageScaleAxesIndependently];
    
    NSView * backgroundContenerView = [[NSView alloc] initWithFrame:screenFrame];
    [backgroundContenerView addSubview:backgroundView];
    
    [self.view addSubview:backgroundContenerView];
     */
    
    /*searchfield - can't manage to get the focus
    screenFrame = [[NSScreen mainScreen] frame];
    float width = 200;
    searchField = [[NSSearchField alloc] initWithFrame:NSMakeRect((screenFrame.size.width - width) / 2 , screenFrame.size.height * 0.90, width, 50)];
    
    [self.view addSubview:searchField];*/
     
    
    [self viewDidLoad];
}

-(void)viewWillLoad {
    // Initializing the model in order to query the database
    launchpadHelper = [[LaunchpadDatabaseHelper alloc] init];
    
    // Get notification when the dock database file is modified (see in LaunchpadDatabaseHelper)
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(refreshView) name:@"VDKQueueFileWrittenToNotification" object:nil];
}

-(void)viewDidLoad {
    // Refresh screenFrame in case of res changing
    screenFrame = [[NSScreen mainScreen] frame];
    
    // documentView is the view which will contain all the pages (inside the scrollView)
    documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, [[launchpadHelper getPages] count] * screenFrame.size.width, screenFrame.size.height)];
    
    currentPage = 0;
    
    // scrollView to allow scrolling between pages
    scrollView = [[ScrollView alloc] initWithFrame: [[NSScreen mainScreen] frame]];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setRulersVisible:NO];
    [scrollView setDrawsBackground:NO];
    [scrollView setDocumentView: documentView];
    [scrollView setDelegate:self];
    [scrollView setDisableSrollWheel:YES];
    isScrolling = NO;
    
    // saving the clipview, to be able to modify programmaticaly the scroll position
    clipView = [scrollView contentView];
    
    //[self _debugViewPositionning:documentView];
    
    [self.view addSubview:scrollView];
    
    [self.window makeFirstResponder:searchField];
    
    [self documentViewDidLoad];
}

// Refresh view (for when a change in db happens or when the screen size change)
-(void)refreshView {
    [documentView removeFromSuperview]; // @todo check if every views in documentView are correctly released
    [self viewDidLoad];
}

-(void)documentViewDidLoad {
    // Bellow we scale using percentages, in order to adapt correctly to every screen sizes
    int marginLeft = screenFrame.size.width * 0.12;
    int marginRight = marginLeft;
    int marginTop = screenFrame.size.height * 0.12;
    int marginBottom = screenFrame.size.height * 0.12;
    
    // Get pages from the db
    NSArray *pages = [launchpadHelper getPages];
    
    // pagingView is the little dots at the bottom on the screen which indicate the current page. We use a NSTextView with the "•" caracter to achieve that.
    pagingView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, screenFrame.size.height * 0.07, screenFrame.size.width, 34)];
    [pagingView setAlignment:NSCenterTextAlignment];
    [pagingView setBackgroundColor:[NSColor clearColor]];
    [pagingView setFont:[NSFont fontWithName:@"Arial" size:32]];
    NSString *pagingString = @"";
    
    int c = (int)[pages count];
    for (int i = 0; i < c; i++) {
        NSDictionary *page = pages[i];
        
        // Creating a page
        NSView *pageView = [[NSView alloc] initWithFrame:NSMakeRect(i * screenFrame.size.width + marginLeft, marginBottom, screenFrame.size.width - marginLeft -marginRight, screenFrame.size.height - marginBottom - marginTop)];
        
        // Getting items within the page
        NSArray *items = [launchpadHelper getPageContentForPageId:[[page objectForKey:@"rowid"] intValue]];
        
        // Building views for items, and adding them to the view. (See addIconFromItem:withIndex:toView:)
        int j = 0;
        for (NSDictionary *item in items) {
            [self addIconFromItem: item withIndex: j toView: pageView];
            j++;
        }
        
        pagingString = [pagingString stringByAppendingString:@"• "];
        //[self _debugViewPositionning:pageView];
        [documentView addSubview: pageView];
    }
    [pagingView setString: pagingString];
    
    // Just to adapt the spacing between caracters, we used a space just after the "•" like this: "• " so we adapt the size of all spaces in order to make it look good.
    for (int i = 0; i < c; i++){
        [pagingView setFont:[NSFont fontWithName:@"Arial" size:14] range:NSMakeRange(i * 2 + 1, 1)];
    }
    
    [self.view addSubview: pagingView];
    [self updatePaging];
}

-(NSColor *)_debugRandomColor{
    return [NSColor colorWithCalibratedHue:arc4random() % 256 / 256.0 saturation:( arc4random() % 128 / 256.0 ) + 0.5 brightness:( arc4random() % 128 / 256.0 ) + 0.5 alpha:1.0];
}

-(void)_debugViewPositionning:(NSView *) view{
    view.wantsLayer = YES;
    view.layer.backgroundColor = [self _debugRandomColor].CGColor;
    
    NSTextView *sizeView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 80, 26)];
    [sizeView setAlignment:NSCenterTextAlignment];
    [sizeView setTextColor:[NSColor greenColor]];
    [sizeView setBackgroundColor:[NSColor blackColor]];
    [sizeView setFont:[NSFont fontWithName:@"Courier" size:10]];
    [sizeView setString:[NSString stringWithFormat:@"(%d,%d)\n%dx%d", (int)view.frame.origin.x, (int)view.frame.origin.y, (int)view.frame.size.width, (int)view.frame.size.height]];
    [view addSubview:sizeView];
}

-(void)updatePaging{
    // We reset dots color to a white with small opacity
    [pagingView setTextColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.3]];
    
    // We set the dot caracter representing the currentPage to a solid white color
    [pagingView setTextColor: [NSColor whiteColor] range: NSMakeRange (currentPage * 2, 1)];
}

-(NSView *)addIconFromItem: (NSDictionary *) item withIndex: (int) i toView: (NSView *)pageView{
    int textViewHeight = GRID_APP_TITLE_FONT_SIZE + 10;
    
    // determing width and height, based on screenSize, and spacing scale needed between apps
    float width = pageView.frame.size.width / ((1 + GRID_APP_SPACING_SCALE) * GRID_APP_HORIZONTALY - GRID_APP_SPACING_SCALE);
    float height = (pageView.frame.size.height - GRID_APP_SPACING_SCALE * textViewHeight + GRID_APP_SPACING_SCALE * textViewHeight * GRID_APP_VERTICALY) / (GRID_APP_VERTICALY + GRID_APP_SPACING_SCALE * GRID_APP_VERTICALY - GRID_APP_SPACING_SCALE);
    
    // Taking the smallest dimension to size images
    if ((height-textViewHeight) < width)
        width = height - textViewHeight;
    else
        height = width - textViewHeight;
    
    // Calculating spacing between apps
    float horizontalSpacing = (pageView.frame.size.width - GRID_APP_HORIZONTALY * width) / (GRID_APP_HORIZONTALY - 1);
    float verticalSpacing = (pageView.frame.size.height - GRID_APP_VERTICALY * height) / (GRID_APP_VERTICALY - 1);
    
    // Position of apps from left and from bottom
    float left = (width + horizontalSpacing) * (i % GRID_APP_HORIZONTALY);
    float bottom = pageView.frame.size.height + verticalSpacing - ((height + verticalSpacing) * (i / GRID_APP_HORIZONTALY +1));
    
    // Creating the appView
    NSView *appView = [[NSView alloc] initWithFrame:NSMakeRect(left, bottom, width, height)];
    //[self _debugViewPositionning:appView];
    
    // itemView will be the icon/image
    NSView *itemView;
    
    // Using a transparent NSButton to make the area arround an app or a group clickable (to launch the app or open the group for instance)
    NSButton *clickArea = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, width, height)];
    [clickArea setTag:[[item objectForKey:@"rowid"] intValue]];
    [clickArea setTarget:self];
    [clickArea setTransparent:YES];
    [clickArea setBordered:NO];
    
    // Defining the titleView which will be filled with the app/group name
    NSTextView *titleView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, width, textViewHeight)];
    [titleView setAlignment:NSCenterTextAlignment];
    [titleView setBackgroundColor:[NSColor clearColor]];
    [titleView setTextColor:[NSColor whiteColor]];
    [titleView setFont:[NSFont fontWithName:@"Helvetica Neue Bold" size:13]];
    
    // Adding a textShadow to the text in order to beautify it, and to make it more visible on darker/lighter backgrounds
    NSShadow *textShadow = [[NSShadow alloc] init];
    [textShadow setShadowColor:[NSColor blackColor]];
    [textShadow setShadowOffset:NSMakeSize(-0.7, 0.7)];
    [textShadow setShadowBlurRadius:1];
    [titleView setShadow:textShadow];
    
    int itemType = [[item objectForKey:@"type"] intValue];
    if (itemType == LAUNCHPAD_TYPE_APP) { // If the item is an App
        // We retrieve app infos from the database
        NSDictionary *app = [launchpadHelper getAppFromItem:item];
        [titleView setString: [app objectForKey:@"title"]];
        
        // We fill the itemView with the app icon
        NSImage *image = [[NSImage alloc] initWithData:[launchpadHelper getImageDataFromItem: item]];
        itemView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, textViewHeight, width, height - textViewHeight)];
        [(NSImageView *)itemView setImage: image];
        
        // We define the action on app click
        [clickArea setAction:@selector(appClickAction:)];
        
    } else if(itemType == LAUNCHPAD_TYPE_GROUP) { // If the item is a Group
        // We retrieve group infos from the database
        NSDictionary *group = [launchpadHelper getGroupFromItem:item];
        [titleView setString: [group objectForKey:@"title"]];
        
        // We retrieve items inside the group
        NSArray *insideItems = [launchpadHelper getContentFromGroup:group];
        
        // We generate the folder icon (background with rounded borders)
        NSImage *background = [self generateGroupViewBackgroundImage];
        
        // Sizes and positionnings of the groupView
        int groupViewSideSize = (height - textViewHeight) * 0.9; // the scale is to let some space for the shadow
        int groupViewBottom = ((height - textViewHeight) - groupViewSideSize) / 2 + textViewHeight;
        int groupViewLeft = (width - groupViewSideSize)/ 2;
        
        // Generating the border
        // > Starting with drawing a gradient within a block
        NSCustomImageRep *gradientImageRep = [[NSCustomImageRep alloc] initWithSize:NSMakeSize(groupViewSideSize, groupViewSideSize) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
            NSGradient* aGradient = [[NSGradient alloc]
                                     initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]
                                     endingColor:[NSColor colorWithCalibratedWhite:0.6 alpha:1.0]];
            [aGradient drawInRect:dstRect angle:270];
            return YES;
        }];
        // > Using the representation to generate an NSImage
        NSImage *gradientImage = [[NSImage alloc] initWithSize:[gradientImageRep size]];
        [gradientImage addRepresentation: gradientImageRep];
        // > Using this NSImage to generate a gradient NSColor
        NSColor *borderColor = [NSColor colorWithPatternImage:gradientImage];
        
        // Generating the box shadow
        NSShadow *boxShadow = [[NSShadow alloc] init];
        
        [boxShadow setShadowColor:[NSColor blackColor]];
        [boxShadow setShadowOffset:NSMakeSize(-0.3, -0.7)];
        [boxShadow setShadowBlurRadius:1.2];
        
        // Finaly creating the background for the group, using shadows, borders, background image generated before and radius
        itemView = [[NSView alloc] initWithFrame:NSMakeRect(groupViewLeft, groupViewBottom, groupViewSideSize, groupViewSideSize)];
        [itemView setShadow:boxShadow];
        [itemView setWantsLayer:YES];
        [itemView.layer setBackgroundColor:[NSColor colorWithPatternImage: background].CGColor];
        [itemView.layer setCornerRadius:GRID_GROUP_BORDER_RADIUS];
        itemView.layer.borderColor = borderColor.CGColor;
        itemView.layer.borderWidth = GRID_GROUP_BORDER_SIZE;
        
        
        // How much items to display
        int c = (int)[insideItems count];
        
        // No more than 9 previews for a group
        if (c > 9)
            c = 9;
        
        // Computing previews side sizes using side size of the group icon
        int imageSideSize = groupViewSideSize * 0.25;
        
        // Iterating over all previews to display
        for (int i = 0; i < c; i++) {
            // Computing preview positions
            float imageViewLeft = groupViewSideSize * 0.12 + imageSideSize * 1.1 * (i % 3);
            float imageViewBottom = groupViewSideSize * 0.12 + imageSideSize * 1.1 * ((8 - i) / 3);
            
            // Loading preview image from database and creating an imageView from it
            NSImage *image = [[NSImage alloc] initWithData:[launchpadHelper getImageDataFromItem: [insideItems objectAtIndex:i]]];
            NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(imageViewLeft, imageViewBottom, imageSideSize, imageSideSize)];
            [imageView setImage: image];
            
            // Adding the imageView to the group icon view
            [itemView addSubview:imageView];
        }
        
    }
    
    // Adding title, icon and clickable area to the appView, added to the page
    [appView addSubview:titleView];
    [appView addSubview:itemView];
    [appView addSubview:clickArea];
    [pageView addSubview:appView];
    
    return appView;
}

- (NSImage *)generateGroupViewBackgroundImage
{
    //-- Initialisation
    
    // That's the linen texture included in AppKit
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

// This method is delegated from ScrollView and is called everytime there is a scroll with the mouse, at every step
-(void)scrollWheel:(NSEvent *)theEvent{
    // If we are scrolling to an other page (with an animation), then we do nothing to not disturb the page changing
    if (isScrolling)
        return;
    
    int pageDirection = [self getPageDirection];
    
    if (pageDirection!=0){
        [self scrollToPage: currentPage + pageDirection];
    } else {
        // If pageDirection is 0 (we do not need to change page), and the scrolling is still occuring, then we manualy move the clipView, so that when the user scroll, the views are still moving accordingly, and we get the effet of pulling the new page
        NSPoint origin = [clipView bounds].origin;
        origin.x -= theEvent.scrollingDeltaX * 0.5;
        [clipView setBoundsOrigin:origin];
        
        /* moving background - too slow
        NSRect bgFrame = backgroundView.frame;
        bgFrame.origin.x += theEvent.scrollingDeltaX * 0.1;
        [backgroundView setFrame: bgFrame];*/
    }
}

-(void)scrollViewDidEndScrolling{
    // Once the scrolling is finished, we animate the page changing. If getPageDirection is 0 and no page changing is needed, we still animate it to make the page go back to the center (we reset the scroll).
    [self scrollToPage: currentPage + [self getPageDirection]];
}

//  Check if the scrolling has reach a point where we can change page (1 for nextPage, -1 for previous page, 0 if we still stay on the currentPage
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


// Animate the scrolling to a new Page
-(void)scrollToPage: (int) page{
    // Already scrolling, so we don't continue
    if(isScrolling)
        return;
    
    // Lock the scrolling to avoid user scrolling interactions
    isScrolling = YES;
    
    // Things to animate will be between beginGrouping and endGrouping
    [NSAnimationContext beginGrouping];
    
    // Once the animation is finished, we unlock the scrolling
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        isScrolling = NO;
    }];
    
    // Calculating the new clipView position depending of the page
    NSPoint newOrigin = [clipView bounds].origin;
    newOrigin.x = page * screenFrame.size.width;
    
    // What to change using the animator
    [[clipView animator] setBoundsOrigin:newOrigin];
    
    [NSAnimationContext endGrouping];
    
    currentPage = page;
    [self updatePaging];
}

// What happens when we click on an app view
-(void)appClickAction:(NSButton *) sender{
    NSDictionary *app = [launchpadHelper getAppWithItemId:(int)sender.tag];
    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:[app objectForKey:@"bundleid"] options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:nil];
}

@end