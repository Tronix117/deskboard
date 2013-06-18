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

- (NSArray *)getItemsWithParentId: (int) parentId;
- (NSArray *)getItemsWithParentId: (int) parentId andType: (int) type;
- (NSArray *)getPages;
- (NSArray *)getPageContentForPageId: (int) itemId;
- (NSDictionary *)getGroupWithItemId: (int) itemId;
- (NSDictionary *)getGroupFromItem: (NSDictionary *) item;
- (NSDictionary *)getAppWithItemId: (int) itemId;
- (NSDictionary *)getAppFromItem: (NSDictionary *) item;
- (NSData *)getImageDataWithItemId: (int) itemId;
- (NSData *)getImageDataFromItem: (NSDictionary *) item;

- (NSArray *)getApps;

@end
