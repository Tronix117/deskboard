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
    return [_database query: [NSString stringWithFormat:@"SELECT * FROM items WHERE parent_id = %d;", parentId]];
}

- (NSArray *)getItemsWithParentId: (int) parentId andType: (int) type {
    return [_database query: [NSString stringWithFormat:@"SELECT * FROM items WHERE parent_id = %d AND type = %d;", parentId, type]];
}

- (NSArray *)getPages {
    return [self getItemsWithParentId: 1 andType: LAUNCHPAD_TYPE_PAGE];
}

- (NSArray *)getPageContentWithItemId: (int) itemId {
    return [self getItemsWithParentId: itemId];
}

- (NSDictionary *)getGroupWithItemId: (int) itemId {
    NSArray *groups = [_database query: [NSString stringWithFormat:@"SELECT * FROM groups WHERE item_id = %d;", itemId]];
    return [groups objectAtIndex: 0];
}

- (NSDictionary *)getAppWithItemId: (int) itemId {
    NSArray *apps = [_database query: [NSString stringWithFormat:@"SELECT * FROM apps WHERE item_id = %d;", itemId]];
    return [apps objectAtIndex: 0];
}

- (NSArray *)getApps {
    return [_database query: @"SELECT * FROM apps;"];
}

- (void)dealloc {
    [_database close]; // @TODO not good to have the close in dealloc
}

@end
