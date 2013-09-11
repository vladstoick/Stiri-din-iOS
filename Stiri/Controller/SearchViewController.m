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
#import "PageNewsItemsViewController.h"
#import "UIImageView+AFNetworking.h"
#define SEARCH_END @"search_ended"
@interface SearchViewController ()
@property NSString *currentQuerry;
@property NSArray *searchResults;
@property UITableView *tableViewSearch;
@property UIActivityIndicatorView *spinner;
@property NSInteger size;
@property BOOL dataAvailable;
@property NSFetchedResultsController *fetchController;
@end

@implementation SearchViewController
#pragma mark CORE DATA

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
    self.searchBar.showsScopeBar = NO;
    [self.searchBar sizeToFit];
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake( self.view.bounds.size.width/2 , 20);
    [NewsDataSource newsDataSource].searchResultDelegate = self;
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
    self.searchResults = nil;
    self.dataAvailable = YES;
    self.currentQuerry = searchString;
    [[NewsDataSource newsDataSource] searchOnlineText:searchString fromIndex:0];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

- (void) recievedSearchResults:(NSArray *)searchResults withDataLeft:(BOOL)dataAvailable{
    if(self.searchResults != nil){
        NSMutableArray *finalResults = [self.searchResults mutableCopy];
        [finalResults addObjectsFromArray:searchResults];
        self.searchResults = finalResults;
    } else {
        self.searchResults = searchResults;
    }
    self.dataAvailable = dataAvailable;
    if(dataAvailable == NO){
        [self.spinner stopAnimating];
    }
    [self.tableViewSearch reloadData];
}


//TABLE VIEW
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.tableView != tableView){
        self.tableViewSearch = tableView;
    }
    self.size = self.searchResults.count;
    self.size += self.dataAvailable == YES;
    return self.size;
}

- (BOOL) isCellResult:(NSInteger) position{
    if(self.dataAvailable == YES && position == self.size - 1 ){
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showSearchResults" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showSearchResults"]){
        NSIndexPath *indexPath = [self.tableViewSearch indexPathForSelectedRow];
        PageNewsItemsViewController *destViewController = segue.destinationViewController;
        destViewController.news = self.searchResults;
        destViewController.newsIndex = indexPath.row;
        destViewController.isFromSearch = YES;
        [self.tableView deselectRowAtIndexPath:indexPath animated:false];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell<NewsItemCellProtocol> *cell;
    if([self isCellResult:indexPath.row]){
        id<NewsItemProtocol> newsItem = [self.searchResults objectAtIndex:indexPath.row];
        NSLog(@"%@",newsItem.imageUrl);
        if(![newsItem.imageUrl isEqualToString:@""] && newsItem.imageUrl != nil ){
            NSString *identifier = @"newsCellWithImage";
            cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        } else {
            NSString *identifier = @"newsCellWithoutImage";
            cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        }
        [cell setNewsItem:newsItem];
    } else {
        NSString *identifier = @"newsCellWithoutImage";
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        cell.titleLabel.text = @"";
        cell.dateLabel.text = @"";
        [cell addSubview:self.spinner];
        [self.spinner startAnimating];
        if(indexPath.row > 0 ){
            [[NewsDataSource newsDataSource] searchOnlineText:self.currentQuerry fromIndex:self.size - 1 ];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self isCellResult:indexPath.row]){
        return 78.0;
    }
    return 40.0;
}

@end
