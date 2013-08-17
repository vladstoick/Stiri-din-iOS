//
//  NewsDataSource.h
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsGroup.h"
#import "NewsItem.h"    
#import "NewsSource.h"
@interface NewsDataSource : NSObject
@property (nonatomic) BOOL isDataLoaded;
@property (readonly, strong, nonatomic) NSArray *allGroups;
@property (nonatomic) NSUInteger userId;
//INITIALIZATION
+ (NewsDataSource*) newsDataSource;
- (void) loadData;
//NEWSGROUP
- (void) addNewsSourceWithUrl:(NSString*) url inNewGroupWithName:(NSString* ) groupTitle;
- (NSArray*) allGroups;
- (NewsGroup*) getGroupWithId:(NSNumber *) groupId;
//NEWSOURCE
- (void) addNewsSourceWithUrl:(NSString*) sourceUrl inNewsGroup:(NewsGroup* ) newsGroup;
- (NSArray*) allSources;
- (NewsSource *) getNewsSourceWithId:(NSNumber *) sourceId;
//NewsItem
- (NSArray*) allItems;
- (NewsItem*) getNewsItemWithUrl:(NSString *) url fromSourceWithId:(NSNumber *) sourceId;

@end
