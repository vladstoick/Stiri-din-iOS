//
//  AllGroupsViewController.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsGroupViewController.h"
#import "SVProgressHud.h"
#import "HHPanningTableViewCell.h"
#import "NewsDataSource.h"
#import "AFNetworking.h"
#import "NewsGroup.h"
#import "NewsSourceViewController.h"
#import "UIViewController+MMDrawerController.h"
#import <QuartzCore/QuartzCore.h>
#define DATA_CHANGED_EVENT @"data_changed"
#define DELETE_END @"delete_ended"
#define DELETE_SUCCES @"delete_succes"
#define DELETE_FAIL @"delete_fail"
@interface NewsGroupViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) NSIndexPath *swipedCell;
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

- (NSArray *) groups{
    _groups = [[NewsDataSource newsDataSource] allGroups];
    return _groups;
}

- (IBAction)addItem:(id)sender{
    [self performSegueWithIdentifier:@"showAddTabController" sender:self];

}

- (IBAction)openMenu:(id)sender{
    if([self.mm_drawerController openSide] == nil){
        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    } else {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = true;
    self.isDataLoading = YES;
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataChanged:) name:DATA_CHANGED_EVENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMessage:) name:DELETE_END object:nil];
    if([NewsDataSource newsDataSource].isDataLoaded == NO){
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
    }
            

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.tableView reloadData];
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

//DELETE AND RENAME
- (IBAction)shouldDeleteGroup:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    self.swipedCell = [self.tableView indexPathForRowAtPoint:buttonPosition];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You can't undo this operation" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void) deleteMessage:(NSNotification*) event{
    if([event.object isEqual: DELETE_SUCCES]){
        [SVProgressHUD showSuccessWithStatus:@"Deleted"];
        [self.tableView reloadData];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Failed"];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView.title isEqualToString:@"Warning"]){
        [[NewsDataSource newsDataSource] deleteNewsGroup:[self.groups objectAtIndex:self.swipedCell.row]];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    }
}


//TALBE VIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showNewsSourceForGroup" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subtitleTableIdentifier = @"panningCell";
    HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    if (cell == nil) {
        cell = [[HHPanningTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:subtitleTableIdentifier];
    }
    UIView *drawerView = [[UIView alloc] initWithFrame:cell.frame];
    drawerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_dotted"]];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake( (cell.frame.size.width/2 - 102)/2  , 10, 102, 24);
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"delete_button.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(shouldDeleteGroup:) forControlEvents:UIControlEventTouchDown];
    UIButton *renameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [renameButton setBackgroundImage:[UIImage imageNamed:@"rename_button.png"] forState:UIControlStateNormal];
    renameButton.frame = CGRectMake(cell.frame.size.width/2 + (cell.frame.size.width/2 - 102)/2 , 10 , 102, 24);
    [drawerView addSubview:renameButton];
    [drawerView addSubview:deleteButton];
    cell.drawerView = drawerView;
    cell.directionMask =  HHPanningTableViewCellDirectionLeft;
    NewsGroup *ng = (self.groups)[indexPath.row];
    cell.textLabel.text = ng.title;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0];
    NSUInteger numberOfNewSources = ng.newsSources.count;
    NSString *surseDeStiriString = [NSString stringWithFormat:@"%d news sources",numberOfNewSources];
    if(numberOfNewSources == 1 ){
        surseDeStiriString = [NSString stringWithFormat:@"one news source"];
    }
    cell.detailTextLabel.text = surseDeStiriString;
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14.0];
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
