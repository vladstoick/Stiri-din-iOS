//
//  NewsGroup.h
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NewsSource;

@interface NewsGroup : NSManagedObject

@property(nonatomic, retain) NSNumber *groupId;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSSet *newsSources;
@end

@interface NewsGroup (CoreDataGeneratedAccessors)

- (void)addNewsSourcesObject:(NewsSource *)value;

- (void)removeNewsSourcesObject:(NewsSource *)value;

- (void)addNewsSources:(NSSet *)values;

- (void)removeNewsSources:(NSSet *)values;

@end
