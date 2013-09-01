//
//  AllNewsItemsViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/27/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "AllNewsItemsViewController.h"
#import "NewsItem.h"
#import "PageNewsItemsViewController.h"
#import "NewsDataSource.h"
#import "NewsItemCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+MMDrawerController.h"
@interface AllNewsItemsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *unreadNews;
@end

@implementation AllNewsItemsViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) updateNews {
    self.unreadNews = [[NewsDataSource newsDataSource] unreadNewsItems];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Unread news"];
    [self updateNews];
}

- (void)viewWillAppear:(BOOL)animated{
    [self updateNews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.unreadNews.count;
}

- (NewsItemCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *unreadNews = @"unreadNews";
    NewsItemCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:unreadNews];
    NewsItem *newsItem;
    newsItem = (self.unreadNews)[indexPath.row];
    cell.titleLabel.text = newsItem.title;
    cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:newsItem.pubDate
                                                         dateStyle:NSDateFormatterShortStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    if([newsItem.imageUrl isEqualToString:@""]){
        [cell.articleImageView setImage:nil];
    } else {
        [cell.articleImageView setImageWithURL:[NSURL URLWithString:newsItem.imageUrl] placeholderImage:[UIImage imageNamed:@"blankimg.png"]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openNewsItem"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PageNewsItemsViewController *destViewController = segue.destinationViewController;
        destViewController.news = self.unreadNews;
        destViewController.newsIndex = indexPath.row;
        [self.tableView deselectRowAtIndexPath:indexPath animated:false];
    }
}

- (IBAction)menuClicked:(id)sender {
    if([self.mm_drawerController openSide] == MMDrawerSideLeft){
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    } else {
        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    
}
@end
