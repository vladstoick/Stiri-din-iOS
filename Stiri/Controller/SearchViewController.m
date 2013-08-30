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
@property UITableView *tableView;
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
	// Do any additional setup after loading the view.
}

- (void) searchRecived:(NSNotification*) notification{
    self.searchResults = notification.object;
        [self.tableView reloadData];
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
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [[NewsDataSource newsDataSource] searchOnlineText:searchText];

}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsScopeBar = YES;
    [self.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchBar;
    return YES;
}

//TABLE VIEW
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.tableView = tableView;
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
