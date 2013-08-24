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
#define RAILSBASEURL @"http://stiriromania.eu01.aws.af.cm/user/"
#define PARSEBASEURL @"http://37.139.8.146:3000/?url="
#define DATA_CHANGED_EVENT @"data_changed"
#define DATA_NEWSOURCE_PARSED @"newssource_loaded"

@interface NewsDataSource ()
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation NewsDataSource
//INITALIZATION
static NewsDataSource *_newsDataSource;

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
        [_newsDataSource loadData];
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

- (void)parseNewsSource:(NewsSource *)newsSource {
    NSString *urlString = [NSString stringWithFormat:@"%@%@&feedId=%@", PARSEBASEURL,
                                                     newsSource.url, newsSource.sourceId];
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

    }         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error recieved : %@", error);
    }];
}

- (void)loadData {
    self.isDataLoaded = NO;
    NSString *urlString = [NSString stringWithFormat:@"%@%d", RAILSBASEURL, self.userId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];

    [httpClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary;
        jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        [self insertGroupsAndNewsSource:jsonDictionary];
        self.isDataLoaded = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CHANGED_EVENT object:nil];
    }           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.isDataLoaded = YES;

    }];

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
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        newsSource.sourceId = [jsonDictionary valueForKey:@"feed_id"];
        newsSource.groupOwner = ng;
        [set addObject:newsSource];
        ng.newsSources = set;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CHANGED_EVENT object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:ADD_ENDED object:nil];

        }
    }            failure:^(AFHTTPRequestOperation *operation, NSError *error) {

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
- (NSArray *)allItems {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsItem"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *newsItems = [context executeFetchRequest:fetchRequest error:nil];
    return newsItems;
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

//INSERTING DATA


- (void)insertGroupsAndNewsSource:(NSDictionary *)jsonData; {
    [self deleteAllNewsGroupsAndNewsSources];
    NSManagedObjectContext *context = [self managedObjectContext];
    for (NSDictionary *groupJSONOBject in jsonData) {
        NSNumber *groupId = [groupJSONOBject valueForKey:@"group_id"];
        NSString *title = [groupJSONOBject valueForKey:@"group_title"];
        NewsGroup *newsGroup = [NSEntityDescription insertNewObjectForEntityForName:@"NewsGroup"
                                                             inManagedObjectContext:context];
        newsGroup.groupId = groupId;
        newsGroup.title = title;
        NSDictionary *allSourcesJSONObject = [groupJSONOBject valueForKey:@"group_feeds"];
        NSMutableSet *sourcesForGroup = [[NSMutableSet alloc] init];
        for (NSDictionary *sourceJSONObject in allSourcesJSONObject) {
            NSNumber *sourceId = [sourceJSONObject valueForKey:@"id"];
            NSString *title = [sourceJSONObject valueForKey:@"title"];
            NSString *sourceDescription = [sourceJSONObject valueForKey:@"description"];
            NSString *url = [sourceJSONObject valueForKey:@"url"];
            NewsSource *newsSource = [NSEntityDescription insertNewObjectForEntityForName:@"NewsSource"
                                                                   inManagedObjectContext:context];
            newsSource.groupOwner = newsGroup;
            newsSource.title = title;
            newsSource.url = url;
            newsSource.sourceId = sourceId;
            newsSource.isFeedParsed = @0;
            [sourcesForGroup addObject:newsSource];
            [self parseNewsSource:newsSource];
        }
        newsGroup.newsSources = sourcesForGroup;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

- (void)insertNewsItems:(NSArray *)articles forNewsSource:(NewsSource *)newsSource {
    NSManagedObjectContext *context = [self managedObjectContext];
    newsSource = [self getNewsSourceWithId:newsSource.sourceId];
    NSMutableSet *news = [[NSMutableSet alloc] init];
    for (NSDictionary *articleJSONObject in articles) {
        NSString *url = [articleJSONObject valueForKey:@"url"];
        NSString *title = [articleJSONObject valueForKey:@"title"];
        NSString *paperized = [articleJSONObject valueForKey:@"text"];
        NSNumber *dateMS = [articleJSONObject valueForKey:@"date"];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[dateMS longLongValue]/1000];
        if ((NSNull *) paperized == [NSNull null]) {
            paperized = @"Loading";
        }
        NewsItem *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"NewsItem"
                                                           inManagedObjectContext:context];
        newsItem.pubDate = date;
        newsItem.url = url;
        newsItem.title = title;
        newsItem.paperized = paperized;
        [news addObject:newsItem];

    }
    newsSource.isFeedParsed = @1;
    newsSource.news = news;
    NSError *error;
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_NEWSOURCE_PARSED object:nil];
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}
//DELETE DATA

- (void)deleteAllNewsGroupsAndNewsSources {
    NSManagedObjectContext *context = [self managedObjectContext];
    for (NSManagedObject *group in self.allGroups) {
        [self.managedObjectContext deleteObject:group];
    }
    for (NSManagedObject *source in self.allSources) {
        [self.managedObjectContext deleteObject:source];
    }
    for (NSManagedObject *newsItem in self.allItems) {
        [self.managedObjectContext deleteObject:newsItem];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

@end

