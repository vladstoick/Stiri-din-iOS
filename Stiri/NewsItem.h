//
//  NewsItem.h
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsItem : NSObject
@property NSString *title;
@property NSString *description;
@property NSURL *url;
-(id) initWithTitle:(NSString*) title andDescription:(NSString*) description
             andUrl: (NSURL*) url;
@end
