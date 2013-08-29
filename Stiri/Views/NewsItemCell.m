//
//  NewsItemCell.m
//  Stiri
//
//  Created by Vlad Stoica on 8/29/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsItemCell.h"

@implementation NewsItemCell

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

@end
