//
//  NewsDataSource.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsDataSource.h"
#import "NewsGroup.h"
#import "NewsItem.h"
#import "NewsSource.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#define RAILSBASEURL @"http://stiriromania.eu01.aws.af.cm/user/"
#define PARSEBASEURL @"http://37.139.8.146:3000/?url="
#define DATA_CHANGED_EVENT @"data_changed"
#define DATA_NEWSOURCE_PARSED @"newssource_loaded"
@interface NewsDataSource()
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@end

@implementation NewsDataSource
//INITALIZATION
static NewsDataSource *_newsDataSource;

- (NSUInteger) userId{
    if(_userId == 0 ){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _userId = [defaults integerForKey:@"user_id"];
    }
    return _userId;
}

+ (NewsDataSource*) newsDataSource{
    if(!_newsDataSource){
        _newsDataSource = [[NewsDataSource alloc] init];
        [_newsDataSource loadData];
    }
    return _newsDataSource;
}
-(NSManagedObjectContext *) managedObjectContext{
    if(!_managedObjectContext){
        AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (void) parseNewsSource:(NewsSource *) newsSource{
    NSString *urlString = [NSString stringWithFormat:@"%@%@&feedId=%@",PARSEBASEURL,newsSource.url,newsSource.sourceId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: [responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options: NSJSONReadingMutableContainers
                                                                        error: nil];
        NSArray *articles = [jsonDictionary valueForKey:@"articles"];
        [self insertNewsItems:articles forNewsSource:newsSource];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error recieved : %@",error);
    }];
}

- (void) loadData{
    NSString *urlString = [NSString stringWithFormat:@"%@%d",RAILSBASEURL,self.userId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [httpClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: [responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options: NSJSONReadingMutableContainers
                                                                         error: nil];
        [self insertGroupsAndNewsSource:jsonDictionary];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
  
    }];

}

//NEWSGROUP
- (NSArray*) allGroups{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsGroup"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *groups = [context executeFetchRequest:fetchRequest error:nil];

    return groups;
}
- (NewsGroup*) getGroupWithId:(NSNumber *) groupId{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsGroup"
                                              inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"groupId = %@",groupId]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    return results[0];
}

//NEWSSOURCE


- (NSArray*) allSources{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsSource"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *sources = [context executeFetchRequest:fetchRequest error:nil];
    return sources;
    
}


- (NewsSource *) getNewsSourceWithId:(NSNumber *) sourceId{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsSource"
                                              inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"sourceId = %@",sourceId]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    return results[0];
}

//NEWSITEM
- (NSArray*) allItems{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsItem"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *newsItems = [context executeFetchRequest:fetchRequest error:nil];
    return newsItems;
}

//INSERTING DATA


- (void) insertGroupsAndNewsSource:(NSDictionary *)jsonData;
{
    [self deleteAllNewsGroupsAndNewsSources];
    NSManagedObjectContext *context = [self managedObjectContext];
    for(NSDictionary* groupJSONOBject in jsonData){
        NSNumber *groupId = [groupJSONOBject valueForKey:@"group_id"];
        NSString *title = [groupJSONOBject valueForKey:@"group_title"];
        NewsGroup *newsGroup = [NSEntityDescription insertNewObjectForEntityForName:@"NewsGroup" inManagedObjectContext:context];
        newsGroup.groupId = groupId;
        newsGroup.title = title;
        NSDictionary *allSourcesJSONObject = [groupJSONOBject valueForKey:@"group_feeds"];
        NSMutableSet *sourcesForGroup = [[NSMutableSet alloc]init];
        for(NSDictionary *sourceJSONObject in allSourcesJSONObject){
            NSNumber *sourceId = [sourceJSONObject valueForKey:@"id"];
            NSString *title = [sourceJSONObject valueForKey:@"title"];
            NSString *sourceDescription = [sourceJSONObject valueForKey:@"description"];
            NSString *url = [sourceJSONObject valueForKey:@"url"];
            NewsSource *newsSource = [NSEntityDescription insertNewObjectForEntityForName:@"NewsSource" inManagedObjectContext:context];
            newsSource.groupOwner = newsGroup;
            newsSource.title = title;
            newsSource.url = url;
            newsSource.sourceId = sourceId;
            newsSource.sourceDescription = sourceDescription;
            newsSource.isFeedParsed=@0;
            [sourcesForGroup addObject:newsSource];
            [self parseNewsSource:newsSource];
        }
        newsGroup.newsSources = sourcesForGroup;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CHANGED_EVENT object:nil];
}

- (void) insertNewsItems:(NSArray*) articles forNewsSource:(NewsSource*) newsSource{
    NSManagedObjectContext *context = [self managedObjectContext];
    newsSource = [self getNewsSourceWithId:newsSource.sourceId];
    NSMutableSet *news = [[NSMutableSet alloc]init];
    for(NSDictionary *articleJSONObject in articles){
        NSString *url = [articleJSONObject valueForKey:@"url"];
        NSString *title = [articleJSONObject valueForKey:@"title"];
        NSString *paperized = [articleJSONObject valueForKey:@"description"];
        if((NSNull*)paperized == [NSNull null]){
            paperized=@"Loading";
        }
        NewsItem *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"NewsItem" inManagedObjectContext:context];
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

- (void) deleteAllNewsGroupsAndNewsSources{
    NSManagedObjectContext *context = [self managedObjectContext];
    for( NSManagedObject* group in self.allGroups){
        [self.managedObjectContext deleteObject:group];
    }
    for( NSManagedObject *source in self.allSources){
        [self.managedObjectContext deleteObject:source];
    }
    for( NSManagedObject *newsItem in self.allItems){
        [self.managedObjectContext deleteObject:newsItem];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}
@end

