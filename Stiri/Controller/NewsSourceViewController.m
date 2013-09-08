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
#import "UIImageView+AFNetworking.h"
#import "HHPanningTableViewCell.h"
#import "SVProgressHUD.h"
#import "SIAlertView.h"
#define DELETE_END @"delete_ended"
#define DELETE_SUCCES @"delete_succes"
#define DELETE_FAIL @"delete_fail"
@interface NewsSourceViewController ()
@property (weak, nonatomic) NSIndexPath *swipedCell;
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

- (HHPanningTableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subtitleTableIdentifier = @"subtitleViewCellSource";
    
    HHPanningTableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    
    if (cell == nil) {
        cell = [[HHPanningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:subtitleTableIdentifier];
    }
    //FRONT VIEW
    NewsSource *ns = (self.newsSources)[indexPath.row];
    if([ns.imageUrl isEqualToString:@""]){
        [cell.imageView setImage:[UIImage imageNamed:@"blankimgfavico.png"]];
    } else {
        [cell.imageView setFrame:CGRectMake(0, 0, 20, 20)];
        [cell.imageView setImageWithURL:[NSURL URLWithString:ns.imageUrl] placeholderImage:[UIImage imageNamed:@"blankimgfavico.png"]];
    }

    cell.textLabel.text = ns.title;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0];
    //BACK VIEW
    UIView *drawerView = [[UIView alloc] initWithFrame:cell.frame];
    drawerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_dotted"]];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake( (cell.frame.size.width/2 - 102/2)  , 10, 102, 24);
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"delete_button.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(shouldDeleteSource:) forControlEvents:UIControlEventTouchDown];
    [drawerView addSubview:deleteButton];
    cell.drawerView = drawerView;
    cell.directionMask =  HHPanningTableViewCellDirectionLeft + HHPanningTableViewCellDirectionRight;

    return cell;
}

//DELETE SOURCE

- (IBAction)shouldDeleteSource:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    self.swipedCell = [self.tableView indexPathForRowAtPoint:buttonPosition];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete news source",nil)
                                                     andMessage:NSLocalizedString(@"You can't undo this operation",nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel",nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
        HHPanningTableViewCell *cell = (HHPanningTableViewCell*)[self.tableView cellForRowAtIndexPath:self.swipedCell];
        [cell setDrawerRevealed:NO animated:YES];
    }];
    [alertView addButtonWithTitle:NSLocalizedString(@"Ok",nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [[NewsDataSource newsDataSource] deleteNewsSource:[self.newsSources objectAtIndex:self.swipedCell.row]];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    [alertView show];
}

- (void) deleteMessage:(NSNotification*) event{
    if([event.object isEqual: DELETE_SUCCES]){
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Deleted",nil)];
        [self.tableView reloadData];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed",nil)];
    }
}

@end
