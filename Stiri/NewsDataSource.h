//
//  NewsDataSource.h
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsDataSource : NSObject
@property NSMutableArray *groups;
@property int userId;
- (void) loadData: (NSDictionary*) jsonData;
@end
