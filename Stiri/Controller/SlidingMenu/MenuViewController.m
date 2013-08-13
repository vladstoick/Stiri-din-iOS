//
//  MenuViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()
@property NSArray *menuItems;
@property NSMutableArray *allMenuItems;
@property NSArray* newsItems;
@property NSArray* settings;
@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.newsItems = @[@"Stirile tale",@"Search"];
    self.settings = @[@"Setari",@"Logout"];
    self.menuItems = @[self.newsItems,self.settings];
    self.allMenuItems = [self.newsItems mutableCopy];
    [self.allMenuItems addObjectsFromArray:self.settings];
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.menuItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *currentSection = [self.menuItems objectAtIndex:section];
    return currentSection.count;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0) return @"Stiri";
    return @"Setari";
}

- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subtitleTableIdentifier = @"menuViewCell";
    
    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subtitleTableIdentifier];
    }
    NSString *menuItem = [self.allMenuItems objectAtIndex:indexPath.row];
    cell.textLabel.text = menuItem;
    return cell;
}


@end
