//
//  SearchViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/17/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "SearchViewController.h"
#import "NewsItemCell.h"
#import "MenuViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "NewsDataSource.h"
#define SEARCH_END @"search_ended"
@interface SearchViewController ()
@property NSArray *searchResults;
@property UITableView *tableViewSearch;
@property UIActivityIndicatorView *spinner;
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
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake( self.view.bounds.size.width/2 , 20);
}

- (void) searchRecived:(NSNotification*) notification{
    [self.spinner stopAnimating];
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
    self.searchResults = [[NSArray alloc] init];
    [self.tableViewSearch reloadData];
    [self.tableViewSearch addSubview:self.spinner];
    [self.spinner startAnimating];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

//TABLE VIEW
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.tableView != tableView){
        self.tableViewSearch = tableView;
    }
    if(self.searchResults == nil) return 0;
    return self.searchResults.count;
}

- (NewsItemCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *searchResultsTableIdentifier = @"searchResultsCell";
    
    NewsItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:searchResultsTableIdentifier];
    NewsItem *newsItem = [self.searchResults objectAtIndex:indexPath.row];
    cell.titleLabel.text = newsItem.title;
    NSString *dateString = [NSDateFormatter localizedStringFromDate:newsItem.pubDate
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    cell.dateLabel.text = dateString;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 78.0;
}

@end
