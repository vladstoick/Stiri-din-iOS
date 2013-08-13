//
//  AllGroupsViewController.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsGroupViewController.h"
#import "NewsDataSource.h"
#import "AFNetworking.h"
#import "SVProgressHud.h"
#import "NewsGroup.h"
#import "NewsSourceViewController.h"
#import "ECSlidingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuViewController.h"
#define DATA_CHANGED_EVENT @"data_changed"
@interface NewsGroupViewController ()
@property (strong, nonatomic) NewsDataSource *newsDataSource;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isDataLoading;
@property (nonatomic) int userId;
@end
@implementation NewsGroupViewController

- (UIRefreshControl *) refreshControl{
    if(!_refreshControl) _refreshControl = [[UIRefreshControl alloc] init];
    return _refreshControl;
}

- (NewsDataSource *) newsDataSource{
    if(!_newsDataSource) _newsDataSource = [NewsDataSource newsDataSource];
    return _newsDataSource;
}

- (NSArray *) groups{
    _groups = [self.newsDataSource allGroups];
    return _groups;
}

- (IBAction)addItem:(id)sender{
    [self performSegueWithIdentifier:@"showAddTabController" sender:self];

}

- (IBAction)openMenu:(id)sender{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setTitle:@"Grupurile tale"];
    self.navigationItem.hidesBackButton = true;
    self.isDataLoading = YES;
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataChanged:) name:DATA_CHANGED_EVENT object:nil];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.slidingViewController setAnchorRightRevealAmount:200.0f];
    self.navigationController.view.layer.shadowOpacity = 0.75f;
    self.navigationController.view.layer.shadowRadius = 10.0f;
    self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem=barBtnItem;
    
}

- (void) refresh {
    if(self.isDataLoading == NO){
        [[NewsDataSource newsDataSource]loadData];
        self.isDataLoading = YES;
    }
}

- (void) dataChanged:(NSNotification*) event{
    self.isDataLoading=NO;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subtitleTableIdentifier = @"subtitleViewCellGroup";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:subtitleTableIdentifier];
    }
    NewsGroup *ng = (self.groups)[indexPath.row];
    cell.textLabel.text = ng.title;
    NSUInteger numberOfNewSources = ng.newsSources.count;
    NSString *surseDeStiriString = [NSString stringWithFormat:@"%d surse de stiri",numberOfNewSources];
    if(numberOfNewSources == 1 ){
        surseDeStiriString = [NSString stringWithFormat:@"o sursă de știri"];
    }
    cell.detailTextLabel.text = surseDeStiriString;
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if( [segue.identifier isEqualToString:@"showNewsSourceForGroup"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NewsSourceViewController *destViewController = segue.destinationViewController;
        NewsGroup *selectedNewsGroup = [self.groups objectAtIndex:indexPath.row];
        destViewController.groupId = selectedNewsGroup.groupId;
        [self.tableView deselectRowAtIndexPath:indexPath animated:false];
    }
}
@end
