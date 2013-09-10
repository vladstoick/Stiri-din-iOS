//
//  NewsItemWithoutImageCell.h
//  Stiri
//
//  Created by Vlad Stoica on 9/9/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem.h"
@interface NewsItemWithoutImageCell : UITableViewCell
@property (weak,nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UILabel *dateLabel;
- (void) setNewsItem:(NewsItem*) newsItem;
@end
