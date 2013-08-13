//
//  NewsDataSource.h
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsDataSource : NSObject
@property (readonly, strong, nonatomic) NSArray *allGroups;
@property (nonatomic) int userId;

+ (NewsDataSource*) newsDataSource;
- (void) insertGroupsAndNewsSource: (NSArray*) groups;
- (NSArray*) allGroups;
@end
