//
//  NewsSource.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsSource.h"

@implementation NewsSource
-(id) initWithTitle:(NSString *)title andDescription:(NSString *)description{
    self = [super init];
    if(self)
    {
        self.title = title;
        self.description = description;
    }
}
@end
