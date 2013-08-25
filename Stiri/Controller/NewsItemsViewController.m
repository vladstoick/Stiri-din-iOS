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

#define DATA_NEWSOURCE_PARSED @"newssource_loaded"

@interface NewsItemsViewController ()
@property(readonly, nonatomic) NewsSource *newsSource;
@property(strong, nonatomic) NSArray *unreadNews;
@property(strong, nonatomic) NSArray *readNews;
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkIfParsed:self.newsSource];
    self.title = self.newsSource.title;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataChanged:)
                                                 name:DATA_NEWSOURCE_PARSED object:nil];
    // Do any additional setup after loading the view.
}

- (void)dataChanged:(NSNotification *)notification {
    [self checkIfParsed:self.newsSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Unread News";
    }
    return @"Old news";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return self.unreadNews.count;
    return self.readNews.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *subtitleTableIdentifier = @"titleViewCellItem";

    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:subtitleTableIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:subtitleTableIdentifier];
    }
    NewsItem *newsItem;
    if(indexPath.section == 0) {
        newsItem = (self.unreadNews)[indexPath.row];
    } else {
        newsItem = (self.readNews)[indexPath.row];
    }
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    cell.textLabel.text = newsItem.title;
    cell.textLabel.font = titleFont;
    cell.textLabel.numberOfLines = 3;
    UIFont *subtitleFont = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:10];
    cell.detailTextLabel.font = subtitleFont;
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:newsItem.pubDate
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterShortStyle];


    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsItem *newsItem;
    if(indexPath.section == 0){
        newsItem = (self.unreadNews)[indexPath.row];
    } else {
        newsItem = (self.readNews)[indexPath.row];
    }
    CGSize size = CGSizeMake(320, 1000);
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];

    CGFloat titleHeight = [newsItem.title sizeWithFont:titleFont
                                     constrainedToSize:size
                                         lineBreakMode:NSLineBreakByCharWrapping].height;
    NSString *pubDate = [NSDateFormatter localizedStringFromDate:newsItem.pubDate
                                                       dateStyle:NSDateFormatterShortStyle
                                                       timeStyle:NSDateFormatterShortStyle];
    UIFont *subtitleFont = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:10];
    CGFloat subtitleHeight = [pubDate sizeWithFont:subtitleFont
                                 constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping].height;
    return titleHeight + subtitleHeight + 20;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openNewsItem"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PageNewsItemsViewController *destViewController = segue.destinationViewController;
        if(indexPath.section == 0){
            destViewController.news = self.unreadNews;
        } else {
            destViewController.news = self.readNews;
        }
        destViewController.newsIndex = indexPath.row;
        [self.tableView deselectRowAtIndexPath:indexPath animated:false];
    }
}
@end
