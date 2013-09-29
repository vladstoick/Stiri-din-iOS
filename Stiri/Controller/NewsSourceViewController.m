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
#import "SVProgressHUD.h"
#import "SIAlertView.h"
#import "NewsSourceCell.h"
#import "MKSlidingTableViewCell.h"
@interface NewsSourceViewController ()
@property (strong, nonatomic) MPAdView *adView;
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
    MPAdView *adView = [[MPAdView alloc] initWithAdUnitId:@"a311136251424e1499ce24f5a8485c35"
                                                      size:MOPUB_BANNER_SIZE];
    adView.frame = CGRectMake(0, self.view.bounds.size.height - 50, 320, 50);
    adView.delegate = self;
    [adView loadAd];
    _adView = adView;
    [self.view addSubview:adView];

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKSlidingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"container"];
    NewsSourceCell *foregroundCell = [tableView dequeueReusableCellWithIdentifier:@"foreground"];
    UITableViewCell *backgroundCell = [tableView dequeueReusableCellWithIdentifier:@"background"];
    //FRONT VIEW
    NewsSource *ns = (self.newsSources)[indexPath.row];
    if([ns.imageUrl isEqualToString:@""]){
        [foregroundCell.favImageView setImage:[UIImage imageNamed:@"blankimgfavico.png"]];
    } else {
        [foregroundCell.favImageView setImageWithURL:[NSURL URLWithString:ns.imageUrl] placeholderImage:[UIImage imageNamed:@"blankimgfavico.png"]];
    }
    foregroundCell.titleLabel.text = ns.title;
    foregroundCell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0];
    cell.backgroundView = backgroundCell;
    cell.foregroundView = foregroundCell;
    cell.drawerView = backgroundCell;
    cell.drawerRevealAmount = 73;
    cell.delegate = self;
    return cell;
}

//DELETE SOURCE

- (IBAction)shouldDeleteSource:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete news source",nil)
                                                     andMessage:NSLocalizedString(@"You can't undo this operation",nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel",nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
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

#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

@end
