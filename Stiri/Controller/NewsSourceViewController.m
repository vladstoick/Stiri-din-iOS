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
#import "NewsSourceCell.h"
@interface NewsSourceViewController ()
@property (weak, nonatomic) NSIndexPath *swipedCell;
@property (strong,nonatomic) NewsGroup* newsGroup;
@property (strong,nonatomic) NSArray* newsSources;
@end

@implementation NewsSourceViewController

- (NewsGroup *) newsGroup{
    if(!_newsGroup){
        _newsGroup = [[NewsDataSource newsDataSource]getGroupWithId:self.groupId];
        [self updateNewsSources];
    }
    return _newsGroup;
}

- (void ) updateNewsSources{
    NSMutableArray *newsSources = [[self.newsGroup.newsSources allObjects] mutableCopy];
    [newsSources sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *id1 = ((NewsSource*)obj1).sourceId;
        NSNumber *id2 = ((NewsSource*)obj2).sourceId;
        return [id1 compare:id2];
    }];
    self.newsSources = newsSources;
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

- (NewsSourceCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"sourceViewCell";
    NewsSourceCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:tableIdentifier];
    //FRONT VIEW
    NewsSource *ns = (self.newsSources)[indexPath.row];
    if([ns.imageUrl isEqualToString:@""]){
        [cell.favImageView setImage:[UIImage imageNamed:@"blankimgfavico.png"]];
    } else {
        [cell.favImageView setImageWithURL:[NSURL URLWithString:ns.imageUrl] placeholderImage:[UIImage imageNamed:@"blankimgfavico.png"]];
    }

    cell.titleLabel.text = ns.title;
    cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0];
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

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete news source",nil)
                                                     andMessage:NSLocalizedString(@"You can't undo this operation",nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel",nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
        HHPanningTableViewCell *cell = (HHPanningTableViewCell*)[self.tableView cellForRowAtIndexPath:self.swipedCell];
        [cell setDrawerRevealed:NO animated:YES];
    }];

    [alertView addButtonWithTitle:NSLocalizedString(@"Ok",nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        self.swipedCell = [self.tableView indexPathForRowAtPoint:buttonPosition];
        [[NewsDataSource newsDataSource] deleteNewsSource:[self.newsSources objectAtIndex:self.swipedCell.row] completion:^(BOOL success) {

            if(success){
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Deleted",nil)];
                self.newsGroup = nil;
                [self updateNewsSources];
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


@end
