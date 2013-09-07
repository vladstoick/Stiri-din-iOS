//
//  AddNewsSourceSelectGroupViewController.h
//  Stiri
//
//  Created by Vlad Stoica on 9/7/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewsSourceSelectGroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSDictionary *feedToBeAdded;
@end
