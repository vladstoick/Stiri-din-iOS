//
//  NewsGroup.h
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsGroup : NSObject
@property NSString *title;
@property NSArray *newsSources;
-(id) initWithTitle: (NSString*) title;
@end
