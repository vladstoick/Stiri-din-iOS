//
//  NewsGroup.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsGroup.h"

@implementation NewsGroup
-(id) initWithTitle:(NSString *)title{
    self = [super init];
    if(self)
        self.title = title;
    return self;
}
@end
