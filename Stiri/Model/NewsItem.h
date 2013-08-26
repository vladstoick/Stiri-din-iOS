//
//  NewsItem.h
//  Stiri
//
//  Created by Vlad Stoica on 8/26/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NewsSource;

@interface NewsItem : NSManagedObject

@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSString * paperized;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NewsSource *sourceOwner;

@end
