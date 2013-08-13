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
#import "FMDatabase.h"
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
//PUBLIC STUFF

- (NSArray*) allGroups{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsGroup"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *groups = [context executeFetchRequest:fetchRequest error:nil];
    return groups;
}

- (NSArray*) allSources{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsSource"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *sources = [context executeFetchRequest:fetchRequest error:nil];
    return sources;
    
}

-(void) insertGroupsAndNewsSource:(NSDictionary *)jsonData;
{
    NSMutableArray *allGroups = [self.allGroups mutableCopy];
    NSManagedObjectContext *context = [self managedObjectContext];
    for(NSDictionary* groupJSONOBject in jsonData){
        NSNumber *groupId = [groupJSONOBject valueForKey:@"group_id"];
        NSString *title = [groupJSONOBject valueForKey:@"group_title"];
        bool existedBefore = false;
        NewsGroup *newsGroup;
        for(NewsGroup *ng in allGroups){
            if([ng.groupId isEqual:groupId]){
                newsGroup = ng;
                newsGroup.title = title;
                existedBefore = true;
                [allGroups removeObject:ng];
                break;
            }
        }
        if(existedBefore==false){
            newsGroup = [NSEntityDescription insertNewObjectForEntityForName:@"NewsGroup" inManagedObjectContext:context];
            newsGroup.groupId = groupId;
            newsGroup.title = title;
        }
        NSDictionary *allSourcesJSONObject = [groupJSONOBject valueForKey:@"group_feeds"];
        NSMutableSet *sourcesForGroup = [[NSMutableSet alloc]init];
        for(NSDictionary *sourceJSONObject in allSourcesJSONObject){
            NSNumber *sourceId = [sourceJSONObject valueForKey:@"id"];
            NSString *title = [sourceJSONObject valueForKey:@"title"];
            NSString *sourceDescription = [sourceJSONObject valueForKey:@"description"];
            NSString *url = [sourceJSONObject valueForKey:@"url"];
            NewsSource *newsSource;
            bool existedBefore = false;
            for(NewsSource *ns in newsGroup.newsSources){
                if([ns.sourceId isEqual:sourceId]){
                    newsSource = ns;
                    newsSource.title = title;
                    newsSource.url = url;
                    newsSource.sourceDescription = sourceDescription;
                    existedBefore = true;
                    break;
                }
            }
            if(existedBefore == false){
                newsSource = [NSEntityDescription insertNewObjectForEntityForName:@"NewsSource" inManagedObjectContext:context];
                newsSource.groupOwner = newsGroup;
                newsSource.title = title;
                newsSource.sourceDescription = sourceDescription;
                newsSource.sourceId = sourceId;
                newsSource.url = url;
            }
            [sourcesForGroup addObject:newsSource];
        }
        newsGroup.newsSources = sourcesForGroup;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    [SVProgressHUD dismiss];
}
@end

