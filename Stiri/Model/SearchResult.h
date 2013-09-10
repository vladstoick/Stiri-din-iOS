//
//  SearchResult.h
//  Stiri
//
//  Created by Vlad Stoica on 9/10/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsItem.h"
@interface SearchResult : NSObject <NewsItemProtocol>
@property (nonatomic,strong) NSString *paperized;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSDate *pubDate;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *imageUrl;
@end
