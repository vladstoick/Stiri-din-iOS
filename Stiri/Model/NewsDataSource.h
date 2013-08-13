//
//  NewsDataSource.h
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsGroup.h"
@interface NewsDataSource : NSObject
@property (readonly, strong, nonatomic) NSArray *allGroups;
@property (nonatomic) NSUInteger userId;
//INITIALIZATION
+ (NewsDataSource*) newsDataSource;
- (void) loadData;
//NEWSGROUP
- (NSArray*) allGroups;
- (NewsGroup*) getGroupWithId:(NSNumber *) groupId;
//NEWSOURCE
- (NSArray*) allSources;
- (NewsSource *) getNewsSourceWithId:(NSNumber *) sourceId;


@end
