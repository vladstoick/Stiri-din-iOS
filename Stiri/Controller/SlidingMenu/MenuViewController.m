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
@property NSArray *sectionTitles;
@property NSMutableArray *allMenuItems;
@property NSArray* newsItems;
@property NSArray* settings;
@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.newsItems = @[@{@"Your news":@"Main"},@{@"Search":@"Search"}];
    self.settings = @[@{@"Settings":@"Settings"},@{@"Logout":@"Logout"}];
    self.sectionTitles = @[@"News",@"Settings"];
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
    return [[self.menuItems objectAtIndex:section] count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.sectionTitles objectAtIndex:section];
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subtitleTableIdentifier = @"menuViewCell";
    
    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subtitleTableIdentifier];
    }
    NSArray *menuItemsForCurrentSection = [self.menuItems objectAtIndex:indexPath.section];
    NSDictionary *menuItem = [menuItemsForCurrentSection objectAtIndex:indexPath.row];
    cell.textLabel.text = [[menuItem allKeys]lastObject];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *menuItemsForCurrentSection = [self.menuItems objectAtIndex:indexPath.section];
    NSDictionary *menuItem = [menuItemsForCurrentSection objectAtIndex:indexPath.row];
    NSString *identifier = [[menuItem allValues]lastObject];
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

@end
