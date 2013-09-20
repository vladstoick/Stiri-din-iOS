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
@property (nonatomic)  NSFetchedResultsController *fetchController;
@end

@implementation SearchViewController
#pragma mark CORE DATA
-(NSFetchedResultsController *)fetchController{
    if(!_fetchController && self.currentQuerry != nil){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title LIKE %@",self.currentQuerry];
        NSManagedObjectContext *context =[NSManagedObjectContext MR_defaultContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setPredicate:predicate];
        [request setFetchBatchSize:20];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsItem" inManagedObjectContext:context];
        [request setEntity:entity];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
        [request setSortDescriptors:@[sortDescriptor]];
        [NSFetchedResultsController deleteCacheWithName:@"unreadNews"];
        self.fetchController= [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                           managedObjectContext:context
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:@"unreadNews"];
        self.fetchController.delegate = self;
        NSError *error;
        [self.fetchController performFetch:&error];
        if(error){
            NSLog(@"%@",error);
        }
    }
    return _fetchController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            [self setCellAtIndexPath:indexPath withCell:(id<NewsItemCellProtocol>)[tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark View Controller
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
#pragma mark SearchDisplay
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.currentQuerry = searchString;
    if(self.searchBar.selectedScopeButtonIndex == 0 ){
        self.searchResults = nil;
        self.dataAvailable = YES;
        [[NewsDataSource newsDataSource] searchOnlineText:searchString fromIndex:0];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains %@",self.currentQuerry];
        [self.fetchController.fetchRequest setPredicate:predicate];
        [self.fetchController performFetch:nil];
    }
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    if(searchOption == 1){
        self.fetchController = nil;
    }
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


#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.tableView != tableView){
        self.tableViewSearch = tableView;
    }
    if(self.searchBar.selectedScopeButtonIndex == 0){
        self.size = self.searchResults.count;
        self.size += self.dataAvailable == YES;
        return self.size;
    }
    id sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
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

- (id<NewsItemProtocol>) objectAtIndex:(NSIndexPath*) indexPath{
    id<NewsItemProtocol> newsItem;
    if(self.searchBar.selectedScopeButtonIndex == 0){
        newsItem = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        newsItem = [self.fetchController objectAtIndexPath:indexPath];
    }
    return newsItem;
}

- (void) setCellAtIndexPath:(NSIndexPath *) indexPath withCell:(id<NewsItemCellProtocol>) tableCell{
    id<NewsItemProtocol> newsItem = [self objectAtIndex:indexPath];
    [tableCell setNewsItem:newsItem];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell<NewsItemCellProtocol> *cell;
    id<NewsItemProtocol> newsItem = [self objectAtIndex:indexPath];
    if([self isCellResult:indexPath.row] || self.searchBar.selectedScopeButtonIndex == 1){
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
