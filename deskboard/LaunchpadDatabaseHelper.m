//
//  LaunchpadDatabaseHelper.m
//  Deskboard
//
//  Created by Jeremy Trufier on 14/06/13.
//  Copyright (c) 2013 Jeremy Trufier. All rights reserved.
//

#import "LaunchpadDatabaseHelper.h"

@implementation LaunchpadDatabaseHelper

- (id)init {
    self = [super init];
    
    if (self) {
        NSDictionary *dbConfig = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"launchpad.db", @"database",
                                    @"/Users/jeremyt/Desktop", @"databaseLocation",
                                    @"YES", @"readonly",
                                    @"SQLite", @"type", nil];
        _database = [[ZIMDbConnection alloc] initWithDictionary: dbConfig withMultithreadingSupport:NO];
    }
    
    return self;
}

- (NSArray *)getItemsWithParentId: (int) parentId {
    return [_database query: [NSString stringWithFormat:@"SELECT * FROM items WHERE parent_id = %d AND flags IS NOT NULL ORDER BY ordering;", parentId]];
}

- (NSArray *)getItemsWithParentId: (int) parentId andType: (int) type {
    return [_database query: [NSString stringWithFormat:@"SELECT * FROM items WHERE parent_id = %d AND type = %d AND flags IS NOT NULL ORDER BY ordering;", parentId, type]];
}

- (NSArray *)getPages {
    return [self getItemsWithParentId: 1 andType: LAUNCHPAD_TYPE_PAGE];
}

- (NSArray *)getPageContentForPageId: (int) itemId {
    return [self getItemsWithParentId: itemId];
}

- (NSDictionary *)getGroupWithItemId: (int) itemId {
    NSArray *groups = [_database query: [NSString stringWithFormat:@"SELECT * FROM groups WHERE item_id = %d;", itemId]];
    if ([groups count] > 0) {
        return [groups objectAtIndex: 0];
    } else {
        return nil;
    }
}

- (NSDictionary *)getGroupFromItem: (NSDictionary *) item {
    return [self getGroupWithItemId:[[item objectForKey:@"rowid"] intValue]];
}

- (NSDictionary *)getAppWithItemId: (int) itemId {
    NSArray *apps = [_database query: [NSString stringWithFormat:@"SELECT * FROM apps WHERE item_id = %d;", itemId]];
    if ([apps count] > 0) {
        return [apps objectAtIndex: 0];
    } else {
        return nil;
    }
}

- (NSDictionary *)getAppFromItem: (NSDictionary *) item {
    return [self getAppWithItemId:[[item objectForKey:@"rowid"] intValue]];
}

- (NSData *)getImageDataWithItemId: (int) itemId {
    NSArray *apps = [_database query: [NSString stringWithFormat:@"SELECT * FROM image_cache WHERE item_id = %d;", itemId]];
    if ([apps count] > 0) {
        return [[apps objectAtIndex: 0] objectForKey:@"image_data"];
    } else {
        return nil;
    }
}

- (NSData *)getImageDataFromItem: (NSDictionary *) item {
    return [self getImageDataWithItemId:[[item objectForKey:@"rowid"] intValue]];
}

- (NSArray *)getApps {
    return [_database query: @"SELECT * FROM apps;"];
}

- (void)dealloc {
    [_database close]; // @TODO not good to have the close in dealloc
}

@end
