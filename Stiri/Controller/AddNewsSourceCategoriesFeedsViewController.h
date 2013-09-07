//
//  AddNewsSourceCategoriesFeedsViewController.h
//  Stiri
//
//  Created by Vlad Stoica on 9/7/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewsSourceCategoriesFeedsViewController : UIViewController <UITableViewDelegate , UITableViewDataSource>
@property (strong,nonatomic) NSArray *feeds;
@property (strong,nonatomic) NSString *categoryTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
