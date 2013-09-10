//
//  AllNewsItemsViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/27/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "AllNewsItemsViewController.h"
#import "NewsItem.h"
#import "PageNewsItemsViewController.h"
#import "NewsDataSource.h"
#import "NewsItemCell.h"
#import "NewsItemWithoutImageCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+MMDrawerController.h"
#import "NSManagedObject+MagicalFinders.h"
@interface AllNewsItemsViewController ()
@property (retain,
        nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AllNewsItemsViewController
//CORE DATA
- (NSFetchedResultsController*) fetchedResultsController{
    if(!_fetchedResultsController){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRead == %@", @0];
//        self.fetchedResultsController = [NewsItem fetchAllGroupedBy:nil withPredicate:nil sortedBy:@"pubDate" ascending:NO];
        NSManagedObjectContext *context =[NSManagedObjectContext MR_defaultContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setPredicate:predicate];
        [request setFetchBatchSize:20];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsItem" inManagedObjectContext:context];
        [request setEntity:entity];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
        [request setSortDescriptors:@[sortDescriptor]];
        [NSFetchedResultsController deleteCacheWithName:@"unreadNews"];
        self.fetchedResultsController= [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                           managedObjectContext:context
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:@"unreadNews"];
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
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
            [self setCellAtIndexPath:indexPath withCell:[tableView cellForRowAtIndexPath:indexPath]];
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}
//COREDATA END
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
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void) setCellAtIndexPath:(NSIndexPath *)indexPath withCell:(UITableViewCell*)cell{
    NewsItem *newsItem = [_fetchedResultsController objectAtIndexPath:indexPath];
    if([newsItem.imageUrl isEqualToString:@""]){
        [(NewsItemWithoutImageCell*)cell setNewsItem: newsItem];
    } else {
        [(NewsItemCell*)cell setNewsItem:newsItem];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;    
    NewsItem *newsItem = [_fetchedResultsController objectAtIndexPath:indexPath];
    if([newsItem.imageUrl isEqualToString:@""]){
        NSString *identifier = @"newsCellWithoutImage";
        cell = [tableViewLocal dequeueReusableCellWithIdentifier:identifier];
    } else {
        NSString *identifier = @"newsCellWithImage";
        cell = [tableViewLocal dequeueReusableCellWithIdentifier:identifier];

    }

    [self setCellAtIndexPath:indexPath withCell:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 78.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"openNewsItem" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openNewsItem"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PageNewsItemsViewController *destViewController = segue.destinationViewController;
        destViewController.news = [self.fetchedResultsController fetchedObjects];
        destViewController.newsIndex = indexPath.row;
        [self.tableView deselectRowAtIndexPath:indexPath animated:false];
    }
}

- (IBAction)menuClicked:(id)sender {
    if([self.mm_drawerController openSide] == MMDrawerSideLeft){
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    } else {
        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    
}
@end
