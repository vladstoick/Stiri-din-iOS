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

@protocol SearchResultDeleagte <NSObject>

- (void) recievedSearchResults:(NSArray*) searchResults withDataLeft:(BOOL) dataAvailable;

@end

@interface NewsDataSource : NSObject
@property(nonatomic) BOOL isDataLoaded;
@property(nonatomic) NSUInteger userId;
@property(nonatomic) NSString* privateKey;
//DELEGATES
@property id<SearchResultDeleagte> searchResultDelegate;
//INITIALIZATION

+ (NewsDataSource *)newsDataSource;

- (void)loadData;

//NEWSGROUP
- (void)deleteNewsGroup:(NewsGroup *)newsGroup;

- (void)renameNewsGroup:(NewsGroup *)newsGroup withNewName:(NSString*) title;

- (void)addNewsSourceWithUrl:(NSString *)url inNewGroupWithName:(NSString *)groupTitle;

- (NSArray *)allGroups;

- (NewsGroup *)getGroupWithId:(NSNumber *)groupId;


//NEWSOURCE
- (void) deleteNewsSource:(NewsSource *) newsSource;

- (void)addNewsSourceWithUrl:(NSString *)sourceUrl inNewsGroup:(NewsGroup *)newsGroup;

- (NSArray *)allSources;

- (NewsSource *)getNewsSourceWithId:(NSNumber *)sourceId;

//NewsItem
- (NSArray *)allNews;

- (NewsItem *)getNewsItemWithUrl:(NSString *)url fromSourceWithId:(NSNumber *)sourceId;

- (void) makeNewsItemRead:(NewsItem *) newsItem;

- (NSArray *) unreadNewsItems;
//RESET DATA

- (void)deleteAllNewsGroupsAndNewsSources;

- (void)logout;

//SEARCH

- (void)searchOnlineText:(NSString *)search fromIndex:(NSInteger) startPosition;
@end
