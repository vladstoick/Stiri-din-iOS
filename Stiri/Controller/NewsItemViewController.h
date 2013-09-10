//
//  NewsItemViewController.h
//  Stiri
//
//  Created by Vlad Stoica on 8/14/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem.h"
@interface NewsItemViewController : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) id<NewsItemProtocol> currentNewsItem;
@property (nonatomic) NSInteger index;
@end
