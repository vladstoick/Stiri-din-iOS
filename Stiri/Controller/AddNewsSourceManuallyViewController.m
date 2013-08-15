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
#define selected_group @"selected_group"
@interface AddNewsSourceManuallyViewController ()
@property (strong, nonatomic) RETableViewSection *section;
@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETextItem *feedTitle;
@property (strong, nonatomic) RETextItem *feedDescription;
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
    self.allGroups = [[NewsDataSource newsDataSource] allGroups];
    self.manager = [[RETableViewManager alloc]initWithTableView:self.tableView];
    self.section = [RETableViewSection sectionWithHeaderTitle:@"Information about the feed"];
    self.feedTitle = [RETextItem itemWithTitle:@"Title" value:@"" placeholder:@"The title of the feed"];
    self.feedDescription = [RETextItem itemWithTitle:@"Description" value:@"" placeholder:@"The description of the feed"];
    self.feedUrl = [RETextItem itemWithTitle:@"RSS" value:@"" placeholder:@"The rss adress of the feed"];
    [self.section addItem:self.feedTitle];
    [self.section addItem:self.feedDescription];
    [self.section addItem:self.feedUrl];
    [self.manager addSection:self.section];
    self.section = [RETableViewSection sectionWithHeaderTitle:@"Information about the group"];
    self.newsGroup = [RERadioItem itemWithTitle:@"Radio" value:@"New Group" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES]; // same as [weakSelf.tableView deselectRowAtIndexPath:item.indexPath animated:YES];
        
        // Generate sample options
        //
        NSMutableArray *options = [[NSMutableArray alloc] init];
        [options addObject:@"New Group"];
        for (NewsGroup *ng in weakSelf.allGroups)
            [options addObject:ng.title];
        
        // Present options controller
        //
        RETableViewOptionsController *optionsController = [[RETableViewOptionsController alloc] initWithItem:item options:options multipleChoice:NO completionHandler:^{
            NSNumber *selectedGroup = @1;
            if(item.indexPath.row == 0){
                selectedGroup = @0;
            }
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:selected_group object:selectedGroup];
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }];
        
        // Adjust styles
        //
        optionsController.delegate = self;
        optionsController.style = self.section.style;
        if (weakSelf.tableView.backgroundView == nil) {
            optionsController.tableView.backgroundColor = weakSelf.tableView.backgroundColor;
            optionsController.tableView.backgroundView = nil;
        }
        
        // Push the options controller
        //
        [weakSelf.navigationController pushViewController:optionsController animated:YES];
    }];
    [self.manager addSection:self.section];
    [self.section addItem:self.newsGroup];
    self.addNewsGroupName = [RETextItem itemWithTitle:@"Group name" value:@"" placeholder:@"The name of the new group"];

    [self.section addItem:self.addNewsGroupName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedGroup:) name:selected_group object:nil];
	// Do any additional setup after loading the view.
}

- (void) selectedGroup:(NSNotification*) notificaiton{
    [self.section removeAllItems];
    [self.section addItem:self.newsGroup];
    if(self.newsGroup.value == @"New Group"){
        [self.section addItem:self.addNewsGroupName];
    }
    [self.section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
