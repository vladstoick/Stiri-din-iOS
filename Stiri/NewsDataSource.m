//
//  NewsDataSource.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsDataSource.h"
#import "NewsGroup.h"
#import "SVProgressHud.h"
@implementation NewsDataSource
-(void) loadData:(NSDictionary *)jsonData;
{
            [SVProgressHUD dismiss];
    for(NSDictionary* group in jsonData){
        NewsGroup *ng;
        NSNumber *id = [group valueForKey:@"group_id"];
        NSString *title = [group valueForKey:@"group_title"];
        ng.title = title;
        ng.id = [id integerValue];
        NSLog(@"%@",ng);
        
    }
}
@end
