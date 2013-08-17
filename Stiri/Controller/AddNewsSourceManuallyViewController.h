//
//  AddNewsSourceManuallyViewController.h
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewsSourceManuallyViewController : UIViewController
- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
