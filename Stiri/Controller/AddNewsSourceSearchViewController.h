//
//  AddNewsSourceSearchViewController.h
//  Stiri
//
//  Created by Vlad Stoica on 9/7/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewsSourceSearchViewController : UIViewController <UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)cancelClicked:(id)sender;

@end
