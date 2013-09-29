//
//  NewsSourceViewController.h
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"
#import "MKSlidingTableViewCell.h"
@interface NewsSourceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPAdViewDelegate,MKSlidingTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSNumber *groupId;
@end
