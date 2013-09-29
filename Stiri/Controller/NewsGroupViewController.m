//
//  AllGroupsViewController.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//
#import "MKSlidingTableViewCell.h"
#import "NewsGroupViewController.h"
#import "SVProgressHud.h"
#import "NewsDataSource.h"
#import "AFNetworking.h"
#import "NewsGroup.h"
#import "NewsSourceViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "SIAlertView.h"
#import <QuartzCore/QuartzCore.h>
#define DATA_CHANGED_EVENT @"data_changed"
@interface NewsGroupViewController ()
@property (strong, nonatomic) NSIndexPath *swipedCell;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isDataLoading;
@end
@implementation NewsGroupViewController

- (UIRefreshControl *) refreshControl{
    if(!_refreshControl) _refreshControl = [[UIRefreshControl alloc] init];
    return _refreshControl;
}

- (NSArray *) groups{
    if(!_groups) _groups = [[NewsDataSource newsDataSource] allGroups];
    return _groups;
}

- (IBAction)addItem:(id)sender{
    [self performSegueWithIdentifier:@"showAddTabController" sender:self];

}

- (IBAction)openMenu:(id)sender{
    if([self.mm_drawerController openSide] == MMDrawerSideLeft){
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];

    } else {
        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeBezelPanningCenterView;
    [self.navigationController setToolbarHidden:YES];
    self.navigationItem.hidesBackButton = true;

    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataChanged:)
                                                 name:DATA_CHANGED_EVENT object:nil];
    if([NewsDataSource newsDataSource].isDataLoaded == NO){
        self.isDataLoading = YES;
        [[NewsDataSource newsDataSource] loadData];
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
    }
            

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.groups = [[NewsDataSource newsDataSource] allGroups];
    [self.tableView reloadData];
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
    self.groups = [[NewsDataSource newsDataSource] allGroups];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//DELETE AND RENAME
- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete group",nil)
                                                     andMessage:NSLocalizedString(@"You can't undo this operation",nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel",nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){}];
    [alertView addButtonWithTitle:NSLocalizedString(@"Ok",nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [[NewsDataSource newsDataSource] deleteNewsGroup:[self.groups objectAtIndex:indexPath.row] completion:^(BOOL success) {
            if(success){
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Deleted",nil)];
                self.groups = [[NewsDataSource newsDataSource] allGroups];
                [self.tableView reloadData];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed",nil)];
            }
        }];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    [alertView show];
}

- (IBAction) shouldRenameGroup:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    self.swipedCell = [self.tableView indexPathForRowAtPoint:buttonPosition];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rename", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Rename",nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    NSString *text = [[alertView textFieldAtIndex:0] text];
    return text.length > 0;

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        NSString *text = [[alertView textFieldAtIndex:0] text];
    if([title isEqualToString:NSLocalizedString(@"Rename",nil)]){
        [[NewsDataSource newsDataSource] renameNewsGroup:[self.groups objectAtIndex:self.swipedCell.row] withNewName:text completion:^(BOOL success) {
            if(success){
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Renamed",nil)];
                self.groups = [[NewsDataSource newsDataSource] allGroups];
                [self.tableView reloadData];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed"];
            }
        }];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Renaming",nil) maskType:SVProgressHUDMaskTypeBlack];
    }
}

//TALBE VIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}
- (void)didSelectSlidingTableViewCell:(MKSlidingTableViewCell *)cell{
    [self performSegueWithIdentifier:@"showNewsSourceForGroup" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKSlidingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"container"];
    UITableViewCell *foregroundCell = [tableView dequeueReusableCellWithIdentifier:@"foreground"];
    UITableViewCell *backgroundCell = [tableView dequeueReusableCellWithIdentifier:@"background"];
    NewsGroup *ng = (self.groups)[indexPath.row];
    foregroundCell.textLabel.text = ng.title;
    foregroundCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0];
    NSUInteger numberOfNewSources = ng.newsSources.count;
    NSString *surseDeStiriString = [NSString stringWithFormat:@"%d %@",numberOfNewSources, NSLocalizedString(@"news sources", nil)];
    if(numberOfNewSources == 1 ){
        surseDeStiriString = [NSString stringWithFormat:NSLocalizedString(@"one news source", nil)];
    }
    foregroundCell.detailTextLabel.text = surseDeStiriString;
    foregroundCell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14.0];

    cell.foregroundView = foregroundCell;
    cell.drawerView = backgroundCell;
    cell.drawerRevealAmount = 146;
    cell.delegate = self;
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
