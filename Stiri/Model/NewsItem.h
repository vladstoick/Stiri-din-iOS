//
//  NewsItem.h
//  Stiri
//
//  Created by Vlad Stoica on 8/15/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NewsSource;

@interface NewsItem : NSManagedObject

@property(nonatomic, retain) NSString *paperized;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSDate *pubDate;
@property(nonatomic, retain) NewsSource *sourceOwner;

@end
