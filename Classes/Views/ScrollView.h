//
//  ScrollView.h
//  Deskboard
//
//  Created by Jeremy Trufier on 19/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScrollView : NSScrollView

@property(assign) id delegate;
@property(assign) BOOL disableSrollWheel;

@end
