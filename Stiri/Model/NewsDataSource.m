//
//  NewsDataSource.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//
#import "NewsDataSource.h"
#import "AFNetworking.h"
#import "CoreData+MagicalRecord.h"
#define FEEDSBASEURL @"http://37.139.26.80/newssource"
#define RAILSBASEURL @"http://37.139.26.80/user/"
#define PARSEBASEURL @"http://37.139.8.146:3000/?feedId="
#define UNREADNEWSURL @"http://37.139.8.146:4000/unread/"
#define READNEWSURL @"http://37.139.8.146:4000/read/"
#define DATA_CHANGED_EVENT @"data_changed"
#define DATA_NEWSOURCE_PARSED @"newssource_loaded"

@interface NewsDataSource ()
@property(nonatomic, readonly) NSDictionary *paramsKey;
@property(nonatomic, strong) NSMutableArray *unreadNews;
@property(nonatomic, strong) NSMutableDictionary *allFeedsMutable;
@end

@implementation NewsDataSource

+ (NewsDataSource *)newsDataSource {
    if (!_newsDataSource) {
        _newsDataSource = [[NewsDataSource alloc] init];
        [_newsDataSource loadFeeds];
    }
    return _newsDataSource;
}

//ADDING DATA
//0. all Feeds are loaded
//1. loadData is Called
//2. loadUnreadNews is called
//3. Once loadUnreadNews process is finished loadGroupsAndSources is called
//4. Once loadGroupsAndSources is finished insertGroupsAndNewsSource is called
//5. parseNewsSource is called for each NewsSource - > after that news are inserted;
- (void)loadFeeds{
    self.allFeedsMutable = [[NSMutableDictionary alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@",FEEDSBASEURL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpClient getPath:@""
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSString *responseStr = [[NSString alloc] initWithData:responseObject
                                                                  encoding:NSUTF8StringEncoding];
                    NSDictionary *json;
                    json = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                           options:NSJSONReadingMutableContainers
                                                             error:nil];
                    NSArray *feeds = [json valueForKey:@"feeds"];
                    for(NSDictionary *feed in feeds){
                        NSString *category = [feed valueForKey:@"category"];
                        if(![self.allFeedsMutable objectForKey:category]){
                            [self.allFeedsMutable setObject:[[NSMutableArray alloc]init] forKey:category];
                        }
                        [(NSMutableArray*)[self.allFeedsMutable objectForKey:category] addObject:feed];
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Recieved error %@",error);
                }];
}
- (void)loadData {
    self.isDataLoaded = NO;
    [self loadUnreadNews];
}

- (void)loadUnreadNews {
    [self.unreadNews removeAllObjects];
    
    NSString *urlstring = [NSString stringWithFormat:@"%@%D", RAILSBASEURL , self.userId];
    NSURL *url = [NSURL URLWithString:urlstring];
    AFHTTPClient *afhttpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [afhttpClient getPath:@"unread"
               parameters:self.paramsKey
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSString *responseStr = [[NSString alloc] initWithData:responseObject
                                                                    encoding:NSUTF8StringEncoding];
                      NSDictionary *json;
                      json = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
                      NSArray* unreadArticles = [json valueForKey:@"articles"];
                      for(NSNumber *ni in unreadArticles){
                          [self.unreadNews addObject:ni];
                      }
                      NSArray *oldUnreadNews = [NewsItem MR_findByAttribute:@"isRead" withValue:@0];
                      for(NewsItem *newsItem in oldUnreadNews){
                          if(![self.unreadNews containsObject:newsItem.newsId]){
                              newsItem.isRead = @1;
                          }
                        }
                      [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
                      [self loadGroupsAndSources];
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"Recieved error %@",error);
                  }];
}

- (void) loadGroupsAndSources {
    NSString *urlString = [NSString stringWithFormat:@"%@%d", RAILSBASEURL, self.userId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient getPath:@""
             parameters:self.paramsKey
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    NSDictionary *json;
                    json = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                           options:NSJSONReadingMutableContainers
                                                             error:nil];
                    [self insertGroupsAndNewsSource:json];
                    self.isDataLoaded = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CHANGED_EVENT object:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Recieved error %@",error);
                }];
}

- (void)insertGroupsAndNewsSource:(NSDictionary *)jsonData; {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSMutableArray *allGroups = [[self allGroups] mutableCopy];
    for (NSDictionary *groupJSONOBject in jsonData) {
        NSNumber *groupId = [groupJSONOBject valueForKey:@"group_id"];
        NSString *title = [groupJSONOBject valueForKey:@"group_title"];
        NewsGroup *newsGroup;
        NSMutableArray *newsSources;
        for(NewsGroup *ng in allGroups){
            if([ng.groupId isEqualToNumber:groupId]){
                newsGroup = ng;
                [allGroups removeObject:ng];
                newsSources = [[newsGroup.newsSources allObjects] mutableCopy];
                break;
            }
        }
        if(newsGroup == nil){
            newsGroup = [NewsGroup MR_createInContext:context];
            newsGroup.groupId = groupId;
        }
        newsGroup.title = title;
        NSDictionary *allSourcesJSONObject = [groupJSONOBject valueForKey:@"group_feeds"];
        for (NSDictionary *sourceJSONObject in allSourcesJSONObject) {
            NewsSource *newsSource;
            NSNumber *sourceId = [sourceJSONObject valueForKey:@"id"];
            NSString *title = [sourceJSONObject valueForKey:@"title"];
            NSString *url = [sourceJSONObject valueForKey:@"url"];
            NSString *imageUrl = [sourceJSONObject valueForKey:@"image"];
            if(newsSources){
                for(NewsSource* ns in newsSources){
                    if([ns.sourceId isEqualToNumber:sourceId]){
                        newsSource = ns;
                        [newsSources removeObject:ns];
                        newsSource.isFeedParsed = @0;
                        break;
                    }
                }
            }
            if(newsSource == nil){
                newsSource = [NewsSource MR_createInContext:context];
                newsSource.groupOwner = newsGroup;
                newsSource.title = title;
                newsSource.url = url;
                newsSource.sourceId = sourceId;
                newsSource.isFeedParsed = @0;
                newsSource.lastTimeUpdated = @0;
                [newsGroup addNewsSourcesObject:newsSource];
            }
            if( (NSNull*) imageUrl == [NSNull null]){
                newsSource.imageUrl = @"";
            } else {
                newsSource.imageUrl = imageUrl;
            }
            [self parseNewsSource:newsSource];
        }
        if(newsSources){
            for(NewsSource* ns in newsSources){
                [ns MR_deleteInContext:context];
            }
        }
        
    }
    for (NewsGroup* newsGroup in allGroups){
        [newsGroup MR_deleteInContext:context];
    }
    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
}

- (void)parseNewsSource:(NewsSource *)newsSource {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PARSEBASEURL, newsSource.sourceId];
    if(![newsSource.lastTimeUpdated isEqualToNumber:@0]){
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&date=%@",newsSource.lastTimeUpdated]];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient getPath:@"" parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    NSDictionary *jsonDictionary;
                    jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
                    NSArray *articles = [jsonDictionary valueForKey:@"articles"];
                    [self insertNewsItems:articles forNewsSource:newsSource];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"error recieved : %@", error);
                }];
}

- (void)insertNewsItems:(NSArray *)articles forNewsSource:(NewsSource *)newsSource {
    NSManagedObjectContext *context = [NSManagedObjectContext defaultContext];
    newsSource = [self getNewsSourceWithId:newsSource.sourceId];
    NSMutableSet *news = [[NSMutableSet alloc] init];
    for (NSDictionary *articleJSONObject in [articles reverseObjectEnumerator]) {
        NSNumber *newsId = [articleJSONObject valueForKey:@"id"];
        NSString *url = [articleJSONObject valueForKey:@"url"];
        NSString *title = [articleJSONObject valueForKey:@"title"];
        NSString *paperized = [articleJSONObject valueForKey:@"text"];
        NSString *imageUrl = [articleJSONObject valueForKey:@"image"];
        NSNumber *dateMS = [articleJSONObject valueForKey:@"date"];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateMS longLongValue] / 1000];
        if([newsSource.lastTimeUpdated compare:dateMS] == NSOrderedDescending){
            break;
        }
        if([newsSource.lastTimeUpdated compare:dateMS] == NSOrderedAscending){
            newsSource.lastTimeUpdated = dateMS;
        }
        if ((NSNull *) paperized == [NSNull null]) {
            paperized = @"Loading";
        }
        NewsItem *newsItem = [NewsItem MR_createInContext:context];
        newsItem.pubDate = date;
        newsItem.newsId = newsId;
        if([self.unreadNews containsObject:newsId]){
            newsItem.isRead = @0;
        } else {
            newsItem.isRead = @1;
        }
        newsItem.url = url;
        newsItem.title = title;
        newsItem.paperized = paperized;
        if((NSNull*) imageUrl == [NSNull null]){
            imageUrl=@"";
        }
        newsItem.imageUrl = imageUrl;
        [news addObject:newsItem];
        
    }
    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
    NSLog(@"Added : %iu news for newsSource :  %@",[news allObjects].count, newsSource.sourceId);
    newsSource.isFeedParsed = @1;
    [newsSource addNews:news];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_NEWSOURCE_PARSED object:nil];
}


//INITALIZATION
static NewsDataSource *_newsDataSource;

- (NSMutableArray *)unreadNews {
    if (!_unreadNews) _unreadNews = [[NSMutableArray alloc] init];
    return _unreadNews;
}

- (NSDictionary *)paramsKey{
    return @{@"key":self.privateKey};
}

- (NSUInteger)userId {
    if (_userId == 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _userId = [defaults integerForKey:@"user_id"];
    }
    return _userId;
}

- (NSString*)privateKey{
    if(!_privateKey){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _privateKey = [defaults stringForKey:@"key"];
        NSLog(@"%@",_privateKey);
    }
    return _privateKey;
}

//NEWSGROUP

- (void)renameNewsGroup:(NewsGroup *)newsGroup withNewName:(NSString *)title completion:(void (^)(BOOL))completionBlock{
    NSString *urlString = [NSString stringWithFormat:@"%@%d/%@",RAILSBASEURL,self.userId,newsGroup.groupId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *params = @{@"title" : title, @"key" : self.privateKey};
    AFHTTPClient *httpCient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpCient putPath:@""
             parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    newsGroup.title = title;
                    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
                    completionBlock(YES);
    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    completionBlock(NO);
    }];
}

- (void)deleteNewsGroup:(NewsGroup *)newsGroup completion:(void (^)(BOOL))completionBlock{
    NSString *urlString = [NSString stringWithFormat:@"%@%d", RAILSBASEURL, self.userId];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpClient deletePath:[NSString stringWithFormat:@"%@", newsGroup.groupId]
                parameters:self.paramsKey
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [newsGroup MR_deleteEntity];
                     [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
                     completionBlock(YES);
            }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    completionBlock(NO);
    }];
}

- (void)addNewsSourceWithUrl:(NSString *)sourceUrl inNewGroupWithName:(NSString *)groupTitle completion:(void (^)(BOOL))completionBlock{
    NSString *urlString = [NSString stringWithFormat:@"%@%d", RAILSBASEURL, self.userId];
    NSDictionary *params = @{@"title" : groupTitle, @"key": self.privateKey};
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpClient postPath:@""
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                     NSDictionary *jsonDictionary;
                     jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:nil];
                     NewsGroup *newsGroup = [NewsGroup MR_createEntity];
                     newsGroup.groupId = [jsonDictionary valueForKey:@"group_id"];
                     newsGroup.title = groupTitle;
                     [self addNewsSourceWithUrl:sourceUrl inNewsGroup:newsGroup completion:completionBlock];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     completionBlock(NO);
                     NSLog(@"%@",error);
    }];
}

- (NSArray *)allGroups {
    return [NewsGroup MR_findAllSortedBy:@"groupId" ascending:YES];
}

- (NewsGroup *)getGroupWithId:(NSNumber *)groupId {
    return [[NewsGroup MR_findByAttribute:@"groupId" withValue:groupId] lastObject];
}

//NEWSSOURCE

- (void) deleteNewsSource:(NewsSource *)newsSource completion:(void (^)(BOOL))completionBlock{
    NSString *urlString = [NSString stringWithFormat:@"%@%d/%@", RAILSBASEURL, self.userId, newsSource.groupOwner.groupId];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpClient deletePath:[NSString stringWithFormat:@"%@",newsSource.sourceId]
                parameters:self.paramsKey
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       [newsSource MR_deleteEntity];
                       [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
                       completionBlock(YES);
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       completionBlock(NO);
                   }];
}

- (void)addNewsSourceWithUrl:(NSString *)sourceUrl inNewsGroup:(NewsGroup *)newsGroup completion:(void (^)(BOOL))completionBlock {
    NSLog(@"%@",completionBlock);
    NSManagedObjectContext *context = [NSManagedObjectContext defaultContext];
    NSString *urlString = [NSString stringWithFormat:@"%@%d/%@", RAILSBASEURL, self.userId, newsGroup.groupId];
    NSDictionary *params = @{@"url" : sourceUrl, @"key": self.privateKey};
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpClient postPath:@""
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                     NSDictionary *jsonDictionary;
                     jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:nil];
                     NewsSource *newsSource = [NewsSource MR_createInContext:context];
                     NewsGroup *ng = [self getGroupWithId:newsGroup.groupId];
                     NSMutableSet *set = [ng.newsSources mutableCopy];
                     newsSource.title = [jsonDictionary valueForKey:@"title"];
                     newsSource.url = sourceUrl;
                     newsSource.sourceId = [jsonDictionary valueForKey:@"id"];
                     newsSource.groupOwner = ng;
                     NSString *imageUrl = [jsonDictionary valueForKey:@"image"];
                     if( (NSNull*) imageUrl == [NSNull null]){
                         newsSource.imageUrl = @"";
                     } else {
                         newsSource.imageUrl = imageUrl;
                     }
                     [set addObject:newsSource];
                     ng.newsSources = set;
                     [self parseNewsSource:newsSource];
                    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CHANGED_EVENT object:nil];
                     completionBlock(YES);
    }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     completionBlock(NO);
    }];
}

- (NSArray *)allSources {
    return [NewsSource MR_findAll];
}


- (NewsSource *)getNewsSourceWithId:(NSNumber *)sourceId {
    return [[NewsSource MR_findByAttribute:@"sourceId" withValue:sourceId] lastObject];
}

- (BOOL) hasNewsSourceWithID:(NSNumber*) sourceId{
    NSArray *array = [NewsSource MR_findByAttribute:@"sourceId" withValue:sourceId];
    if(array == nil || array.count == 0 ){
        return NO;
    }
    return YES;
}

//NEWSITEM
- (NSArray *)allNews {
    return [NewsItem MR_findAll];
}


- (void) makeNewsItemRead:(NewsItem *) newsItem{
    if([newsItem.isRead isEqualToNumber:@1]){
        return;
    }
    NSString *urlstring = [NSString stringWithFormat:@"%@%D", RAILSBASEURL , self.userId];
    NSURL *url = [NSURL URLWithString:urlstring];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *paramters = @{@"article_id": newsItem.newsId, @"key": self.privateKey};
    newsItem.isRead = @1;
    [httpClient deletePath:@"unread"
              parameters:paramters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Made News read %@" , newsItem.url);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (NewsItem *)getNewsItemWithUrl:(NSString *)url fromSourceWithId:(NSNumber *)sourceId {
    return [[NewsItem MR_findByAttribute:@"url" withValue:url] lastObject];
}

- (NSArray*) unreadNewsItems{
    return [NewsItem MR_findByAttribute:@"isRead" withValue:@0 andOrderBy:@"pubDate" ascending:NO];
}
//RESET DATA

- (void) logout {
    self.userId = 0;
    [self deleteAllNewsGroupsAndNewsSources];
}

- (void)deleteAllNewsGroupsAndNewsSources {
    self.isDataLoaded = NO;
    NSManagedObjectContext *context = [NSManagedObjectContext defaultContext];
    [NewsGroup MR_truncateAllInContext:context];
    [NewsSource MR_truncateAllInContext:context];
    [NewsItem MR_truncateAllInContext:context];
    [context MR_saveToPersistentStoreAndWait];

}

//SEARCH

- (void)searchOnlineText:(NSString *)search fromIndex:(NSInteger) startPosition{
    NSString *urlString = [NSString stringWithFormat:@"http://37.139.8.146:8983/solr/collection1/select?start=%u&rows=10&wt=json&indent=true&fl=title,content,image,last_modified,url&sort=last_modified+desc&q=content:%@",startPosition,search];
    NSLog(@"%@",urlString);
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject
                                                      encoding:NSUTF8StringEncoding];
        NSDictionary *json;
        json = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        NSDictionary *response = [json valueForKey:@"response"];
        NSNumber *resultsFound = [response valueForKey:@"numFound"];
        NSDictionary *results = [response valueForKey:@"docs"];
        NSMutableArray *searchParsed = [[NSMutableArray alloc] init];

        for(NSDictionary *newsResult in results){
            SearchResult *result = [[SearchResult alloc] init];
            result.paperized = [newsResult valueForKey:@"content"];
            result.title = [newsResult valueForKey:@"title"];
            result.imageUrl = [newsResult valueForKey:@"image"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSString *dateString = [newsResult valueForKey:@"last_modified"];
            NSDate *date = [dateFormatter dateFromString:dateString];
            result.pubDate= date;
            result.url = [newsResult valueForKey:@"url"];
            [searchParsed addObject:result];
        }
        BOOL dataIsLeft = (startPosition+10 < [resultsFound integerValue]);
        [self.searchResultDelegate recievedSearchResults:searchParsed withDataLeft:dataIsLeft];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//ALL FEEDS

- (NSDictionary*) allFeeds{
    return self.allFeedsMutable;
}

@end

