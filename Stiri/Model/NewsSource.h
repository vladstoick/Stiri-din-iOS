//
//  NewsSource.h
//  Stiri
//
//  Created by Vlad Stoica on 8/17/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NewsGroup, NewsItem;

@interface NewsSource : NSManagedObject

@property(nonatomic, retain) NSNumber *isFeedParsed;
@property(nonatomic, retain) NSNumber *sourceId;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NewsGroup *groupOwner;
@property(nonatomic, retain) NSSet *news;
@end

@interface NewsSource (CoreDataGeneratedAccessors)

- (void)addNewsObject:(NewsItem *)value;

- (void)removeNewsObject:(NewsItem *)value;

- (void)addNews:(NSSet *)values;

- (void)removeNews:(NSSet *)values;

@end
