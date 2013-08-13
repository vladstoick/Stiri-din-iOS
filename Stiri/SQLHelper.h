//
//  SQLHelper.h
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@interface SQLHelper : NSObject
//INIT
@property (strong,nonatomic) FMDatabase *database;
- (void) insertNewsGroupsAndNewsSources:(NSArray *)groupsAndSources;
//NEWSGROUP
- (NSArray*) getAllNewsGroups;

@end
