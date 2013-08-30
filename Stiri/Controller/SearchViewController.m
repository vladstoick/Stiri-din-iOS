//
//  SearchViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/17/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "SearchViewController.h"
#import "MenuViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "NewsDataSource.h"
#define SEARCH_END @"search_ended"
@interface SearchViewController ()
@property NSArray *searchResults;
@property UITableView *tableViewSearch;
@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchRecived:) name:SEARCH_END object:nil];
    self.searchBar.showsScopeBar = NO;
    [self.searchBar sizeToFit];
	// Do any additional setup after loading the view.
}

- (void) searchRecived:(NSNotification*) notification{
    self.searchResults = notification.object;
    [self.tableViewSearch reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)menuButtonPressed:(id)sender {
    if([self.mm_drawerController openSide] == MMDrawerSideLeft){
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        
    } else {
        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
}
//SEARCH
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [[NewsDataSource newsDataSource] searchOnlineText:searchString];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
//{
//    self.searchBar.showsScopeBar = YES;
//    [self.searchBar sizeToFit];
//    self.tableView.tableHeaderView = self.searchBar;
//    return YES;
//}

//TABLE VIEW
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.tableView != tableView){
        self.tableViewSearch = tableView;
    }
    if(self.searchResults == nil) return 0;
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *subtitleTableIdentifier = @"searchViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subtitleTableIdentifier];
    }
    NewsItem *newsItem = [self.searchResults objectAtIndex:indexPath.row];
    NSLog(@"%@",newsItem);
    cell.textLabel.text = newsItem.title;
    return cell;
}

@end
