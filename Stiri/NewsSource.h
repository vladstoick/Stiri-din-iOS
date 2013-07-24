//
//  NewsSource.h
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsSource : NSObject
@property NSString *title;
@property NSString *description;
@property NSArray  *news;
-(id) initWithTitle: (NSString*) title andDescription:(NSString*) description;

@end
