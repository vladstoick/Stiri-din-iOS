//
//  NewsItem.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsItem.h"

@implementation NewsItem
-(id) initWithTitle:(NSString *)title andDescription:(NSString *)description
             andUrl:(NSURL *)url{
    self = [super init];
    if(self)
    {
        self.title=title;
        self.description=description;
        self.url=url;
    }
    return self;
}
@end
