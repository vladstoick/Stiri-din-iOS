//
//  SearchViewController.h
//  Stiri
//
//  Created by Vlad Stoica on 8/17/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsDataSource.h"
@interface SearchViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, SearchResultDeleagte>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
