//
//  NewsItemCell.h
//  Stiri
//
//  Created by Vlad Stoica on 8/29/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem.h"
@interface NewsItemCell : UITableViewCell
@property (weak,nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UILabel *dateLabel;
@property (weak,nonatomic) IBOutlet UIImageView *articleImageView;
- (void) setNewsItem:(NewsItem*) newsItem;
@end
