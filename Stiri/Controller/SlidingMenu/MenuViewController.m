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
#import <GooglePlus/GooglePlus.h>
#import "FontAwesomeKit.h"
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
    NSDictionary *yourGroupsDictionary = @{@"title": NSLocalizedString(@"Your groups",nil) , @"img" : FAKIconFolderOpen};
    NSDictionary *unreadNewsDictionary = @{@"title": NSLocalizedString(@"Unread news", nil) , @"img" : FAKIconRssSign };
    NSDictionary *searchDictionary = @{@"title" : NSLocalizedString(@"Search", nil) , @"img" : FAKIconSearch};
    NSDictionary *settingsDictionary = nil;
    NSDictionary *logoutDictionary = @{@"title" : NSLocalizedString(@"Logout", nil) , @"img" : FAKIconOff};
    self.newsItems = @[@{yourGroupsDictionary:@"Main"},
                       @{unreadNewsDictionary:@"AllNewsItems"},
                       @{searchDictionary:@"Search"}];
    self.settings = @[@{logoutDictionary:@"Logout"}];
    self.sectionTitles = @[NSLocalizedString(@"News",nil),
                           NSLocalizedString(@"Settings",nil)];
    self.menuItems = @[self.newsItems,self.settings];
    self.allMenuItems = [self.newsItems mutableCopy];
    [self.allMenuItems addObjectsFromArray:self.settings];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
   

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
}

- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"menuViewCell";
    
    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSArray *menuItemsForCurrentSection = [self.menuItems objectAtIndex:indexPath.section];
    NSDictionary *menuItem = [menuItemsForCurrentSection objectAtIndex:indexPath.row];
    NSDictionary *menuInfo = [[menuItem allKeys] lastObject];
    cell.textLabel.text = [menuInfo valueForKey:@"title"];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    [cell.imageView setImage:[FontAwesomeKit imageForIcon:[menuInfo valueForKey:@"img"] imageSize:CGSizeMake(18, 18) fontSize:18 attributes:nil]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *menuItemsForCurrentSection = [self.menuItems objectAtIndex:indexPath.section];
    NSDictionary *menuItem = [menuItemsForCurrentSection objectAtIndex:indexPath.row];
    NSString *identifier = [[menuItem allValues]lastObject];
    NSString *finalIdentfier = identifier;
    if([identifier isEqualToString:@"Logout"]){
        [SVProgressHUD show];
        finalIdentfier=@"Main";
        [FBSession.activeSession closeAndClearTokenInformation];
        [[GPPSignIn sharedInstance] signOut];
        [[NewsDataSource newsDataSource] logout];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
        [SVProgressHUD dismiss];
        NSIndexPath *mainIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.tableView selectRowAtIndexPath:mainIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        
    }
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:finalIdentfier];
    self.mm_drawerController.centerViewController = newTopViewController;
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
    }];
    
}

@end
