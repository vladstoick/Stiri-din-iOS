//
//  AllNewsItemsViewController.h
//  Stiri
//
//  Created by Vlad Stoica on 8/27/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllNewsItemsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
- (IBAction)menuClicked:(id)sender;

@end
