//
//  NewsSourceViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsSourceViewController.h"
#import "NewsGroup.h"
#import "NewsSource.h"
#import "NewsDataSource.h"
@interface NewsSourceViewController ()
@property (strong, nonatomic) NewsDataSource *newsDataSource;
@property (strong, nonatomic) NSMutableArray *newsSources;
@property (strong, nonatomic) NewsGroup *newsGroup;
@end

@implementation NewsSourceViewController

- (NewsDataSource*) newsDataSource{
    if(!_newsDataSource) _newsDataSource = [NewsDataSource newsDataSource];
    return _newsDataSource;
}

- (NSMutableArray*) newsSources{
    if(!_newsSources) _newsSources = [[NSMutableArray alloc]init];
    return _newsSources;
}

- (NewsGroup *) newsGroup{
    if(!_newsGroup) _newsGroup = [self.newsDataSource getGroupWithId:self.groupId];
    return _newsGroup;
}


- (void) syncNewsSourcesWithNewsGroup {
    [self.newsSources removeAllObjects];
    for(NewsSource *newsSource in self.newsGroup.newsSources){
        [self.newsSources addObject:newsSource];
    }
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
    [self syncNewsSourcesWithNewsGroup];
    self.title = self.newsGroup.title;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.newsSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subtitleTableIdentifier = @"subltileViewCell";
    
    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:subtitleTableIdentifier];
    }
    NewsSource *ns = (self.newsSources)[indexPath.row];
    cell.textLabel.text = ns.title;
    cell.detailTextLabel.text = ns.sourceDescription;
    return cell;
}

@end
