//
//  AllGroupsViewController.h
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsGroupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
