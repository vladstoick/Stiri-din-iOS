//
//  NewsItemCell.h
//  Stiri
//
//  Created by Vlad Stoica on 8/29/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem.h"
@protocol NewsItemCellProtocol <NSObject>
- (void) setNewsItem:(NewsItem*) newsItem;
@property (weak,nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UILabel *dateLabel;
@end
@interface NewsItemCell : UITableViewCell <NewsItemCellProtocol>
@property (weak,nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UILabel *dateLabel;
@property (weak,nonatomic) IBOutlet UIImageView *articleImageView;
- (void) setNewsItem:(NewsItem*) newsItem;
@end
