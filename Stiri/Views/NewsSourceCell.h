//
//  NewsSourceCell.h
//  Stiri
//
//  Created by Vlad Stoica on 9/8/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHPanningTableViewCell.h"
@interface NewsSourceCell : HHPanningTableViewCell
@property (weak,nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UIImageView *favImageView;
@end
