//
//  NewsItemWithoutImageCell.m
//  Stiri
//
//  Created by Vlad Stoica on 9/9/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsItemWithoutImageCell.h"

@implementation NewsItemWithoutImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setNewsItem:(NewsItem *)newsItem{
    self.titleLabel.text = newsItem.title;
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:newsItem.pubDate
                                                         dateStyle:NSDateFormatterShortStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    
    [self setNeedsDisplay];
}

@end
