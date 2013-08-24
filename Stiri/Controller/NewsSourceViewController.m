//
//  NewsSourceViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsSourceViewController.h"
#import "NewsItemsViewController.h"
#import "NewsGroup.h"
#import "NewsSource.h"
#import "NewsDataSource.h"
@interface NewsSourceViewController ()
@property (readonly,nonatomic) NewsGroup* newsGroup;
@property (readonly,nonatomic) NSArray* newsSources;
@end

@implementation NewsSourceViewController

- (NewsGroup *) newsGroup{
    return [[NewsDataSource newsDataSource]getGroupWithId:self.groupId];
}

- (NSArray *) newsSources{
    return [self.newsGroup.newsSources allObjects];
}

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
    self.title = self.newsGroup.title;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showNewsItemsForNewsSource"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NewsItemsViewController *destViewController = segue.destinationViewController;
        
        NewsSource *selectedNewsSource = [self.newsSources objectAtIndex:indexPath.row];
        destViewController.sourceId = selectedNewsSource.sourceId;
        [self.tableView deselectRowAtIndexPath:indexPath animated:false];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.newsSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subtitleTableIdentifier = @"subtitleViewCellSource";
    
    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subtitleTableIdentifier];
    }
    NewsSource *ns = (self.newsSources)[indexPath.row];
    cell.textLabel.text = ns.title;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0];
    return cell;
}

@end
