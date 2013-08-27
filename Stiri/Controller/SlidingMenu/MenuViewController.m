//
//  MenuViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "MenuViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "AllNewsItemsViewController.h"
#import "FBSession.h"
#import "NewsDataSource.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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
    self.tableView.backgroundColor =    [UIColor colorWithPatternImage:[UIImage imageNamed:@"squairy_light.png"]];
    self.newsItems = @[@{@"Your groups":@"Main"},@{@"All News":@"AllNewsItems"},@{@"Search":@"Search"}];
    self.settings = @[@{@"Settings":@"Settings"},@{@"Logout":@"Logout"}];
    self.sectionTitles = @[@"News",@"Settings"];
    self.menuItems = @[self.newsItems,self.settings];
    self.allMenuItems = [self.newsItems mutableCopy];
    [self.allMenuItems addObjectsFromArray:self.settings];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
   

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 26.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 280, 26)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweed.png"]];
    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10,2,250,22)];
    sectionTitle.opaque = true;
    sectionTitle.backgroundColor = [UIColor clearColor];
    sectionTitle.textColor = [UIColor whiteColor];
    sectionTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    sectionTitle.text = [self tableView:tableView titleForHeaderInSection:section];
    [headerView addSubview:sectionTitle];
    return headerView;
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
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *menuItemsForCurrentSection = [self.menuItems objectAtIndex:indexPath.section];
    NSDictionary *menuItem = [menuItemsForCurrentSection objectAtIndex:indexPath.row];
    NSString *identifier = [[menuItem allValues]lastObject];
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        NSString *finalIdentfier = identifier;
        if(identifier==@"Logout"){
            [SVProgressHUD show];
            finalIdentfier=@"Main";
            [FBSession.activeSession closeAndClearTokenInformation];
            [[NewsDataSource newsDataSource] deleteAllNewsGroupsAndNewsSources];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
            [SVProgressHUD dismiss];
            NSIndexPath *mainIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.tableView selectRowAtIndexPath:mainIndexPath animated:NO scrollPosition:0];

        }
        UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:finalIdentfier];
        self.mm_drawerController.centerViewController = newTopViewController;       
    }];
    
}

@end
