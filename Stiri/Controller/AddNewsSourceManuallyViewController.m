//
//  AddNewsSourceManuallyViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "AddNewsSourceManuallyViewController.h"
#import "RETableViewOptionsController.h"
#import "RETableViewManager.h"
#import "NewsDataSource.h"
#import "SVProgressHud.h"
#define ADD_ENDED @"add_ended"
#define selected_group @"selected_group"
@interface AddNewsSourceManuallyViewController ()
@property (strong, nonatomic) RETableViewSection *section;
@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETextItem *feedUrl;
@property (strong, nonatomic) RERadioItem *newsGroup;
@property (strong, nonatomic) RETextItem *addNewsGroupName;
@property (strong, nonatomic) NSArray* allGroups;
@end

@implementation AddNewsSourceManuallyViewController

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
    __typeof (&*self) __weak weakSelf = self;
    //    self.tabBarController.navigationItem
    self.allGroups = [[NewsDataSource newsDataSource] allGroups];
    self.manager = [[RETableViewManager alloc]initWithTableView:self.tableView];
    self.section = [RETableViewSection sectionWithHeaderTitle:@""];
    self.feedUrl = [RETextItem itemWithTitle:@"RSS" value:nil placeholder:NSLocalizedString(@"The rss adress",nil)];
    [self.section addItem:self.feedUrl];
    self.newsGroup = [RERadioItem itemWithTitle:NSLocalizedString(@"Group",nil) value:NSLocalizedString(@"New Group",nil) selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        NSMutableArray *options = [[NSMutableArray alloc] init];
        [options addObject:NSLocalizedString(@"New Group",nil)];
        for (NewsGroup *ng in weakSelf.allGroups)
            [options addObject:ng.title];
        RETableViewOptionsController *optionsController = [[RETableViewOptionsController alloc] initWithItem:item options:options multipleChoice:NO completionHandler:^{
            NSNumber *selectedGroup = @1;
            if(item.indexPath.row == 0){
                selectedGroup = @0;
            }
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:selected_group object:selectedGroup];
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }];
        optionsController.delegate = self;
        optionsController.style = self.section.style;
        if (weakSelf.tableView.backgroundView == nil) {
            optionsController.tableView.backgroundColor = weakSelf.tableView.backgroundColor;
            optionsController.tableView.backgroundView = nil;
        }
        [weakSelf.navigationController pushViewController:optionsController animated:YES];
    }];
    [self.section addItem:self.newsGroup];
    self.addNewsGroupName = [RETextItem itemWithTitle:NSLocalizedString(@"Group name",nil) value:nil placeholder:@"The name of the new group"];
    [self.section addItem:self.addNewsGroupName];
    [self.manager addSection:self.section];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEnded:) name:ADD_ENDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedGroup:) name:selected_group object:nil];
	// Do any additional setup after loading the view.
}

- (void) selectedGroup:(NSNotification*) notificaiton{
    [self.section removeAllItems];
    [self.section addItem:self.feedUrl];
    [self.section addItem:self.newsGroup];
    if([self.newsGroup.value isEqual: NSLocalizedString(@"New Group",nil)]){
        [self.section addItem:self.addNewsGroupName];
    }
    [self.section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender {
    NSString* sourceUrl = self.feedUrl.value;
    NSString* addGroupName = self.addNewsGroupName.value;
    if([self.newsGroup.value isEqual: NSLocalizedString(@"New Group",nil)]){
        [[NewsDataSource newsDataSource] addNewsSourceWithUrl:sourceUrl inNewGroupWithName:addGroupName];
    } else {
        NewsGroup *newsGroup;
        for(NewsGroup* ng in self.allGroups){
            if([ng.title isEqualToString:self.newsGroup.value]){
                newsGroup = ng;
                break;
            }
        }
        [[NewsDataSource newsDataSource] addNewsSourceWithUrl:sourceUrl inNewsGroup:newsGroup];
    }
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Adding",nil) maskType:SVProgressHUDMaskTypeBlack];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) addEnded:(NSNotification*) notification{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Added",nil)];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end