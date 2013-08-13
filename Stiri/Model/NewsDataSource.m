//
//  NewsDataSource.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsDataSource.h"
#import "NewsGroup.h"
#import "NewsSource.h"
#import "SVProgressHud.h"
#import "AppDelegate.h"
@interface NewsDataSource()
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@end

@implementation NewsDataSource
//INITALIZATION
static NewsDataSource *_newsDataSource;
+ (NewsDataSource*) newsDataSource{
    if(!_newsDataSource){
        _newsDataSource = [[NewsDataSource alloc] init];
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

//INSERTING DATA

-(void) insertGroupsAndNewsSource:(NSDictionary *)jsonData;
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
            [sourcesForGroup addObject:newsSource];
        }
        newsGroup.newsSources = sourcesForGroup;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
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
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}
@end

