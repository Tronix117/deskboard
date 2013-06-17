//
//  LaunchpadDatabaseHelper.h
//  Deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZIMDbSdk.h"
#import "ZIMSqlSdk.h"

#define LAUNCHPAD_TYPE_GROUP 2
#define LAUNCHPAD_TYPE_PAGE 3
#define LAUNCHPAD_TYPE_APP 4

@interface LaunchpadDatabaseHelper : NSObject {
@protected
    ZIMDbConnection *_database;
}

- (NSArray *)getApps;

@end
