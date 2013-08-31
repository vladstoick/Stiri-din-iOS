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
#import "UIViewController+MMDrawerController.h"
@interface AllNewsItemsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *unreadNews;
@property (strong, nonatomic) NSArray *readNews;
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


- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *subtitleTableIdentifier = @"titleViewCellItem";

    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:subtitleTableIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:subtitleTableIdentifier];
    }
    NewsItem *newsItem;
    newsItem = (self.unreadNews)[indexPath.row];
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

- (IBAction)menuClicked:(id)sender {
    if([self.mm_drawerController openSide] == MMDrawerSideLeft){
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    } else {
        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    
}
@end
