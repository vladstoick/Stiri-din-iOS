//
//  NewsDataSource.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//
#import "CoreData+MagicalRecord.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NewsDataSource.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#define SEARCH_END @"search_ended"
#define DELETE_END @"delete_ended"
#define DELETE_SUCCES @"delete_succes"
#define DELETE_FAIL @"delete_fail"
#define ADD_ENDED @"add_ended"
#define ADD_FAIL @"add_fail";
#define ADD_SUCCES @"add_succes";
#define RAILSBASEURL @"http://37.139.26.80/user/"
#define PARSEBASEURL @"http://37.139.8.146:3000/?feedId="
#define UNREADNEWSURL @"http://37.139.8.146:4000/unread/"
#define READNEWSURL @"http://37.139.8.146:4000/read/"
#define SEARCHBASEURL @"http://37.139.8.146:8983/solr/collection1/select?rows=20&wt=json&q=description:"
#define DATA_CHANGED_EVENT @"data_changed"
#define DATA_NEWSOURCE_PARSED @"newssource_loaded"

@interface NewsDataSource ()
@property(nonatomic, strong) NSMutableArray *unreadNews;
@end

@implementation NewsDataSource

//ADDING DATA
//1. loadData is Called
//2. loadUnreadNews is called
//3. Once loadUnreadNews process is finished loadGroupsAndSources is called
//4. Once loadGroupsAndSources is finished insertGroupsAndNewsSource is called
//5. parseNewsSource is called for each NewsSource - > after that news are inserted;
- (void)loadData {
    self.isDataLoaded = NO;
    
    [self loadUnreadNews];
}

- (void)loadUnreadNews {
    [self.unreadNews removeAllObjects];
    NSString *urlstring = [NSString stringWithFormat:@"%@%D", UNREADNEWSURL , self.userId];
    NSURL *url = [NSURL URLWithString:urlstring];
    AFHTTPClient *afhttpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [afhttpClient getPath:@""
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSString *responseStr = [[NSString alloc] initWithData:responseObject
                                                                    encoding:NSUTF8StringEncoding];
                      NSDictionary *json;
                      json = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
                      for(NSDictionary *ni in json){
                          [self.unreadNews addObject:[ni valueForKey:@"id"]];
                      }
                      [self loadGroupsAndSources];
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      
                  }];
}

- (void) loadGroupsAndSources {
    NSString *urlString = [NSString stringWithFormat:@"%@%d", RAILSBASEURL, self.userId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient getPath:@""
             parameters:nil
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
                    self.isDataLoaded = YES;}];
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
            if(newsSources){
                for(NewsSource* ns in newsSources){
                    if([ns.sourceId isEqualToNumber:sourceId]){
                        newsSource = ns;
                        [newsSources removeObject:ns];
                        newsSource.isFeedParsed = @0;
                        break;
                    }
                }
            } else {
                newsSource = [NewsSource MR_createInContext:context];
                newsSource.groupOwner = newsGroup;
                newsSource.title = title;
                newsSource.url = url;
                newsSource.sourceId = sourceId;
                newsSource.isFeedParsed = @0;
                newsSource.lastTimeUpdated = @0;
                [newsGroup addNewsSourcesObject:newsSource];
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
    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreAndWait];
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
    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreAndWait];
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

- (NSUInteger)userId {
    if (_userId == 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _userId = [defaults integerForKey:@"user_id"];
    }
    return _userId;
}

+ (NewsDataSource *)newsDataSource {
    if (!_newsDataSource) {
        _newsDataSource = [[NewsDataSource alloc] init];

    }
    return _newsDataSource;
}

//NEWSGROUP

- (void)deleteNewsGroup:(NewsGroup *)newsGroup {
    NSString *urlString = [NSString stringWithFormat:@"%@%d", RAILSBASEURL, self.userId];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpClient deletePath:[NSString stringWithFormat:@"%@", newsGroup.groupId] parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [newsGroup MR_deleteEntity];
                [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_END  object:DELETE_SUCCES];
                [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_SUCCES object:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_END object:DELETE_FAIL];
    }];
}

- (void)addNewsSourceWithUrl:(NSString *)sourceUrl inNewGroupWithName:(NSString *)groupTitle {
    NSString *urlString = [NSString stringWithFormat:@"%@%d", RAILSBASEURL, self.userId];
    NSDictionary *params = @{@"title" : groupTitle};
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary;
        jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        NewsGroup *newsGroup = [NewsGroup MR_createEntity];
        newsGroup.groupId = [jsonDictionary valueForKey:@"group_id"];
        newsGroup.title = groupTitle;
        [self addNewsSourceWithUrl:sourceUrl inNewsGroup:newsGroup];
    }            failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}

- (NSArray *)allGroups {
    return [NewsGroup MR_findAll];
}

- (NewsGroup *)getGroupWithId:(NSNumber *)groupId {
    return [[NewsGroup MR_findByAttribute:@"groupId" withValue:groupId] lastObject];
}

//NEWSSOURCE

- (void)addNewsSourceWithUrl:(NSString *)sourceUrl inNewsGroup:(NewsGroup *)newsGroup {
    NSManagedObjectContext *context = [NSManagedObjectContext defaultContext];
    NSString *urlString = [NSString stringWithFormat:@"%@%d/%@", RAILSBASEURL, self.userId, newsGroup.groupId];
    NSDictionary *params = @{@"url" : sourceUrl};
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
        [set addObject:newsSource];
        ng.newsSources = set;
        [self parseNewsSource:newsSource];
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CHANGED_EVENT object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_ENDED object:nil];
    }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}

- (NSArray *)allSources {
    return [NewsSource MR_findAll];
}


- (NewsSource *)getNewsSourceWithId:(NSNumber *)sourceId {
    return [[NewsSource MR_findByAttribute:@"sourceId" withValue:sourceId] lastObject];
}

//NEWSITEM
- (NSArray *)allNews {
    return [NewsItem MR_findAll];
}


- (void) makeNewsItemRead:(NewsItem *) newsItem{
    if([newsItem.isRead isEqualToNumber:@1]){
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%d/%@", READNEWSURL, self.userId, newsItem.newsId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    newsItem.isRead = @1;
    [httpClient postPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void)searchOnlineText:(NSString *)search{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",SEARCHBASEURL,search];
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
        NSDictionary *results = [response valueForKey:@"docs"];
        NSMutableArray *searchParsed = [[NSMutableArray alloc] init];
        for(NSDictionary *newsResult in results){
            NewsItem *ni = [NewsItem MR_createEntity];
            ni.title = [newsResult valueForKey:@"title"];
            ni.url = [newsResult valueForKey:@"url"];
            [searchParsed addObject:ni];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_END object:searchParsed];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end

