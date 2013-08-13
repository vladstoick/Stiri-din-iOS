//
//  AllGroupsViewController.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsGroupViewController.h"
#import "NewsDataSource.h"
#import "AFNetworking.h"
#import "SVProgressHud.h"
#import "NewsGroup.h"
#import "NewsSourceViewController.h"
@interface NewsGroupViewController ()
@property (strong, nonatomic) NewsDataSource *newsDataSource;
@property (strong, nonatomic) NSArray *groups;
@property (nonatomic) int userId;
@end
@implementation NewsGroupViewController

- (NewsDataSource *) newsDataSource{
    if(!_newsDataSource) _newsDataSource = [NewsDataSource newsDataSource];
    return _newsDataSource;
}

- (NSArray *) groups{
    if(!_groups) _groups = [[NSArray alloc]init];
    return _groups;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:false animated:true];
    [self.navigationItem setHidesBackButton:YES];
    [super setTitle:@"Grupurile tale"];
    [SVProgressHUD show];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.userId = [defaults integerForKey:@"user_id"];
    self.newsDataSource.userId = self.userId;
    NSString *urlString = [NSString stringWithFormat:@"http://stiriromania.eu01.aws.af.cm/user/%d",self.userId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: [responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options: NSJSONReadingMutableContainers
                                                                         error: nil];
        [self.newsDataSource insertGroupsAndNewsSource:jsonDictionary];
        self.groups = self.newsDataSource.allGroups;
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error recieved : %@",error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subtitleTableIdentifier = @"subtitleViewCell";
    
    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:subtitleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:subtitleTableIdentifier];
    }
    NewsGroup *ng = (self.groups)[indexPath.row];
    cell.textLabel.text = ng.title;
    NSUInteger numberOfNewSources = ng.newsSources.count;
    NSString *surseDeStiriString = [NSString stringWithFormat:@"%d surse de stiri",numberOfNewSources];
    if(numberOfNewSources == 1 ){
        surseDeStiriString = [NSString stringWithFormat:@"o sursă de știri"];
    }
    cell.detailTextLabel.text = surseDeStiriString;
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
