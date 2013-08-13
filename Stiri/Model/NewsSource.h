//
//  NewsSource.h
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NewsGroup;

@interface NewsSource : NSManagedObject

@property (nonatomic, retain) NSNumber * sourceId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NewsGroup *groupOwner;

@end
