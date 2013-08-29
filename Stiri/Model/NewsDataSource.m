//
//  NewsDataSource.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsDataSource.h"
#import "AppDelegate.h"
#import "AFNetworking.h"

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
#define DATA_CHANGED_EVENT @"data_changed"
#define DATA_NEWSOURCE_PARSED @"newssource_loaded"

@interface NewsDataSource ()
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
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
                    self.isDataLoaded = YES;
                    
                }];
}

- (void)insertGroupsAndNewsSource:(NSDictionary *)jsonData; {
    NSMutableArray *allGroups = [[self allGroups] mutableCopy];
    NSManagedObjectContext *context = [self managedObjectContext];
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
            newsGroup = [NSEntityDescription insertNewObjectForEntityForName:@"NewsGroup"
                                                             inManagedObjectContext:context];
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
                newsSource = [NSEntityDescription insertNewObjectForEntityForName:@"NewsSource"
                                                                   inManagedObjectContext:context];
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
                [context deleteObject:ns];
            }
        }
        
    }
    for (NewsGroup* newsGroup in allGroups){
        [context deleteObject:newsGroup];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
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
    NSManagedObjectContext *context = [self managedObjectContext];
    newsSource = [self getNewsSourceWithId:newsSource.sourceId];
    if(articles.count!=0)
        newsSource.lastTimeUpdated = @0;
    NSMutableSet *news = [[NSMutableSet alloc] init];
    for (NSDictionary *articleJSONObject in articles) {
        NSNumber *newsId = [articleJSONObject valueForKey:@"id"];
        NSString *url = [articleJSONObject valueForKey:@"url"];
        NSString *title = [articleJSONObject valueForKey:@"title"];
        NSString *paperized = [articleJSONObject valueForKey:@"text"];
        NSString *imageUrl = [articleJSONObject valueForKey:@"image"];
        NSNumber *dateMS = [articleJSONObject valueForKey:@"date"];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateMS longLongValue] / 1000];
        if([newsSource.lastTimeUpdated isEqualToNumber:@0]){
            newsSource.lastTimeUpdated = dateMS;
        }
        if ((NSNull *) paperized == [NSNull null]) {
            paperized = @"Loading";
        }
        NewsItem *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"NewsItem"
                                                           inManagedObjectContext:context];
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
    newsSource.isFeedParsed = @1;
    [newsSource addNews:news];
    NSError *error;
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_NEWSOURCE_PARSED object:nil];
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
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

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}


//NEWSGROUP

- (void)deleteNewsGroup:(NewsGroup *)newsGroup {
    NSString *urlString = [NSString stringWithFormat:@"%@%d", RAILSBASEURL, self.userId];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpClient deletePath:[NSString stringWithFormat:@"%@", newsGroup.groupId] parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSManagedObjectContext *context = [self managedObjectContext];
                [context deleteObject:newsGroup];
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
        NSManagedObjectContext *context = [self managedObjectContext];
        NewsGroup *newsGroup = [NSEntityDescription insertNewObjectForEntityForName:@"NewsGroup"
                                                             inManagedObjectContext:context];
        newsGroup.groupId = [jsonDictionary valueForKey:@"group_id"];
        newsGroup.title = groupTitle;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        } else {
            [self addNewsSourceWithUrl:sourceUrl inNewsGroup:newsGroup];
        }

    }            failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}

- (NSArray *)allGroups {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsGroup"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *groups = [context executeFetchRequest:fetchRequest error:nil];
    return groups;
}

- (NewsGroup *)getGroupWithId:(NSNumber *)groupId {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsGroup"
                                              inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"groupId = %@", groupId]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    return [results lastObject];
}

//NEWSSOURCE

- (void)addNewsSourceWithUrl:(NSString *)sourceUrl inNewsGroup:(NewsGroup *)newsGroup {
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
        NSManagedObjectContext *context = [self managedObjectContext];

        NewsSource *newsSource = [NSEntityDescription insertNewObjectForEntityForName:@"NewsSource"
                                                               inManagedObjectContext:context];
        NewsGroup *ng = [self getGroupWithId:newsGroup.groupId];
        NSMutableSet *set = [ng.newsSources mutableCopy];
        newsSource.title = [jsonDictionary valueForKey:@"title"];
        newsSource.url = sourceUrl;
        newsSource.sourceId = [jsonDictionary valueForKey:@"id"];
        newsSource.groupOwner = ng;
        [set addObject:newsSource];
        ng.newsSources = set;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        } else {
            [self parseNewsSource:newsSource];
            [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CHANGED_EVENT object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:ADD_ENDED object:nil];
           
        }
    }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}

- (NSArray *)allSources {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsSource"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *sources = [context executeFetchRequest:fetchRequest error:nil];
    return sources;

}


- (NewsSource *)getNewsSourceWithId:(NSNumber *)sourceId {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsSource"
                                              inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"sourceId = %@", sourceId]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    return [results lastObject];
}

//NEWSITEM
- (NSArray *)allNews {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsItem"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *newsItems = [context executeFetchRequest:fetchRequest error:nil];
    return newsItems;
}

- (void) makeNewsItemRead:(NewsItem *) newsItem{
    if([newsItem.isRead isEqualToNumber:@1]){
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%d/%@", READNEWSURL, self.userId, newsItem.newsId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    newsItem = [self getNewsItemWithUrl:newsItem.url fromSourceWithId:newsItem.sourceOwner.sourceId];
    newsItem.isRead = @1;
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    [httpClient postPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Made News read %@" , newsItem.url);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (NewsItem *)getNewsItemWithUrl:(NSString *)url fromSourceWithId:(NSNumber *)sourceId {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsItem" inManagedObjectContext:context];
    NSString *query = [NSString stringWithFormat:@"url = '%@'", url];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    return [results lastObject];
}
//DELETE DATA

- (void)deleteAllNewsGroupsAndNewsSources {
    self.isDataLoaded = NO;
    NSManagedObjectContext *context = [self managedObjectContext];
    for (NSManagedObject *group in self.allGroups) {
        [self.managedObjectContext deleteObject:group];
    }
    for (NSManagedObject *source in self.allSources) {
        [self.managedObjectContext deleteObject:source];
    }
    for (NSManagedObject *newsItem in self.allNews) {
        [self.managedObjectContext deleteObject:newsItem];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

@end

