//
//  NewsItemCell.m
//  Stiri
//
//  Created by Vlad Stoica on 8/29/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsItemCell.h"
#import "UIImageView+AFNetworking.h"
@interface NewsItemCell()
@property (nonatomic,readonly) CGRect defaultRectForImage;
@property (nonatomic,readonly) CGRect defaultRectForTitle;
@property (nonatomic,readonly) CGRect defaultRectForDate;
@property (nonatomic,readonly) CGRect secondaryRectForImage;
@property (nonatomic,readonly) CGRect secondaryRectForTitle;
@property (nonatomic,readonly) CGRect secondaryRectForDate;

@end
@implementation NewsItemCell

- (CGRect)defaultRectForImage{
    return CGRectMake(0, 0, 78, 78);
}

- (CGRect) defaultRectForTitle{
    return CGRectMake(90, 10, 210, 44);
}

- (CGRect)defaultRectForDate{
    return CGRectMake(90, 50, 210, 20);
}

- (CGRect)secondaryRectForImage{
    return CGRectMake(0, 0, 0, 0);
}

- (CGRect)secondaryRectForTitle{
    return CGRectMake(10, 10, 300, 44);
}

- (CGRect)secondaryRectForDate{
   return CGRectMake(10, 50, 300, 20);
}

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
    if([newsItem.imageUrl isEqualToString:@""]){
        [self.articleImageView setFrame:self.secondaryRectForImage];
        [self.titleLabel setFrame:self.secondaryRectForTitle];
        [self.dateLabel setFrame:self.secondaryRectForDate];
    } else {
        [self.articleImageView setFrame:self.defaultRectForImage];
        [self.titleLabel setFrame:self.defaultRectForTitle];
        [self.dateLabel setFrame:self.defaultRectForDate];
        [self.articleImageView setImageWithURL:[NSURL URLWithString:newsItem.imageUrl] placeholderImage:[UIImage imageNamed:@"blankimg.png"]];
    }
    self.titleLabel.text = newsItem.title;
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:newsItem.pubDate
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];

    [self setNeedsDisplay];
}

@end
