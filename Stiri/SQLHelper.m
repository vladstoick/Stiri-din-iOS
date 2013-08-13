//
//  SQLHelper.m
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "SQLHelper.h"
#import "NewsGroup.h"
#define GROUPS_TABLE @"groups"
#define SOURCES_TABLE @"sources"
#define NEWSITEMS_TABLE @"newsItems"
#define COLUMN_GROUP_ID @"groupid"
#define COLUMN_SOURCE_ID @"sourceid"
#define COLUMN_NOFEEDS @"nofeeds"
#define COLUMN_NOUNREADNEWS @"nounreadnews"
#define COLUMN_ID @"id"
#define COLUMN_TITLE @"title"
#define COLUMN_URL @"url"
#define COLUMN_DESCRIPTION @"description"

@implementation SQLHelper
//INIT
- (FMDatabase *)database{
    if(!_database){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *path = [docsPath stringByAppendingPathComponent:@"feeds.sqlite"];
        NSLog(@"%@",path);
        _database=[FMDatabase databaseWithPath:path];
        [_database open];
        NSString *createGroupsQuery = [NSString stringWithFormat:@"CREATE TABLE %@ ( %@ int primary key , %@ text not null , %@ int )",GROUPS_TABLE,COLUMN_ID,COLUMN_TITLE,COLUMN_NOFEEDS];
        [_database executeUpdate:createGroupsQuery];
    }
    return _database;
}
- (void) insertNewsGroupsAndNewsSources:(NSArray *)groupsAndSources{
    for(NewsGroup *group in groupsAndSources){
        NSString *title = group.title;
        NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ ( %d , %@ , %@ ) ", GROUPS_TABLE, group.groupId,group.title,group.newsSources.count];
        [self.database executeQuery:query];
    }
}
//NEWSGROUP
- (NSArray*) getAllNewsGroups{
    NSMutableArray *allGroups = [[NSMutableArray alloc]init];
    NSString *query = [NSString stringWithFormat:@"SELECT * from %@",GROUPS_TABLE];
    FMResultSet *results = [self.database executeQuery:query];
    return allGroups;
}

@end
