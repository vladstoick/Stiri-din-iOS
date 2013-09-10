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
@protocol NewsItemProtocol <NSObject>
@required
@property (nonatomic) NSString * paperized;
@property (nonatomic) NSString *title;
@property (nonatomic) NSDate *pubDate;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *imageUrl;
@end
@interface NewsItem : NSManagedObject <NewsItemProtocol>

@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSString * paperized;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NewsSource *sourceOwner;

@end
