//
//  NewsDataSource.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsDataSource.h"
#import "NewsGroup.h"
#import "SVProgressHud.h"
#import "AppDelegate.h"
#import "FMDatabase.h"
#import "SQLHelper.h"
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

-(void) insertGroupsAndNewsSource:(NSDictionary *)jsonData;
{
    NSArray *allGroups = self.allGroups;
    NSManagedObjectContext *context = [self managedObjectContext];
    for(NSDictionary* groupJSONOBject in jsonData){
        NSNumber *groupId = [groupJSONOBject valueForKey:@"group_id"];
        NSString *title = [groupJSONOBject valueForKey:@"group_title"];
        bool existedBefore = false;
        for(NewsGroup *ng in allGroups){
            if([ng.groupId isEqual:groupId]){
                ng.title = title;
                ng.groupId = groupId;
                existedBefore = true;
                break;
            }
        }
        if(existedBefore==false){
            NewsGroup *newsGroup = [NSEntityDescription insertNewObjectForEntityForName:@"NewsGroup" inManagedObjectContext:context];
            newsGroup.groupId = groupId;
            newsGroup.title = title;
        }
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    [SVProgressHUD dismiss];
}
@end

