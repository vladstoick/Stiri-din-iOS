//
//  NewsItemsViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsItemsViewController.h"
#import "PageNewsItemsViewController.h"
#import "NewsSource.h"
#import "NewsItem.h"
#import "NewsDataSource.h"
#import "SVProgressHud.h"
#import "NewsItemCell.h"
#define DATA_NEWSOURCE_PARSED @"newssource_loaded"
#import "UIImageView+AFNetworking.h"
@interface NewsItemsViewController ()
@property(readonly, nonatomic) NewsSource *newsSource;
@property(strong, nonatomic) NSArray *unreadNews;
@property(strong, nonatomic) NSArray *readNews;
@property(nonatomic) BOOL hasUnreadNews;
@property(nonatomic) BOOL hasReadNews;
@end

@implementation NewsItemsViewController

- (NewsSource *)newsSource {
    NewsSource *localNewsSource = [[NewsDataSource newsDataSource] getNewsSourceWithId:self.sourceId];
    return localNewsSource;
}

- (void)checkIfParsed:(NewsSource *)ns {
    [self updateNews];
    if ([ns.isFeedParsed isEqual:@0]) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    } else {
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    }

}

- (void) updateNews {
    NSMutableArray *array = [[self.newsSource.news allObjects] mutableCopy];
    [array sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(NewsItem *) a pubDate];
        NSDate *second = [(NewsItem *) b pubDate];
        return [second compare:first];
    }];
    NSMutableArray *unreadNews = [[NSMutableArray alloc] init];
    NSMutableArray *readNews = [[NSMutableArray alloc]init];
    for(NewsItem *newsItem in array){
        if([newsItem.isRead isEqualToNumber:@0]){
            [unreadNews addObject:newsItem];
        } else {
            [readNews addObject:newsItem];
        }
    }
    self.hasReadNews = readNews.count > 0;
    self.hasUnreadNews = unreadNews.count > 0;
    self.unreadNews = unreadNews;
    self.readNews = readNews;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self updateNews];
    [self.tableView reloadData];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.isShowingAllNews == NO){
        [self checkIfParsed:self.newsSource];
        self.title = self.newsSource.title;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataChanged:)
                                                 name:DATA_NEWSOURCE_PARSED object:nil];
    // Do any additional setup after loading the view.
}

- (void)dataChanged:(NSNotification *)notification {
    if(self.isShowingAllNews == NO){
        [self checkIfParsed:self.newsSource];
    } else {
        [self updateNews];
        [self.tableView reloadData];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.hasUnreadNews != self.hasReadNews){
        return 1;
    }
    if(self.hasReadNews == self.hasUnreadNews && self.hasUnreadNews == YES){
        return 2;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.hasUnreadNews == YES) {
        return NSLocalizedString(@"Unread news",nil);
    }
    return NSLocalizedString(@"Old news",nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 26.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 280, 26)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweed.png"]];
    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10,2,250,22)];
    sectionTitle.opaque = true;
    sectionTitle.backgroundColor = [UIColor clearColor];
    sectionTitle.textColor = [UIColor whiteColor];
    sectionTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    sectionTitle.text = [self tableView:tableView titleForHeaderInSection:section];
    [headerView addSubview:sectionTitle];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.hasUnreadNews == YES)  return self.unreadNews.count;
    return self.readNews.count;
}


- (NewsItemCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *subtitleTableIdentifier = @"titleViewCellItem";
    NewsItemCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    NewsItem *newsItem;
    if(indexPath.section == 0 && self.hasUnreadNews == YES) {
        newsItem = (self.unreadNews)[indexPath.row];
    } else {
        newsItem = (self.readNews)[indexPath.row];
    }
    [cell setNewsItem:newsItem];
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openNewsItem"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PageNewsItemsViewController *destViewController = segue.destinationViewController;
        if(indexPath.section == 0 && self.hasUnreadNews == YES){
            destViewController.news = self.unreadNews;
        } else {
            destViewController.news = self.readNews;
        }
        destViewController.newsIndex = indexPath.row;
        [self.tableView deselectRowAtIndexPath:indexPath animated:false];
    }
}
@end
