//
//  AllGroupsViewController.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "AllGroupsViewController.h"
#import "NewsDataSource.h"
#import "AFNetworking.h"
#import "SVProgressHud.h"
#import "NewsGroup.h"
@interface AllGroupsViewController ()

@property (strong, nonatomic) NewsDataSource *newsDataSource;
@property (nonatomic) int userId;

@end

@implementation AllGroupsViewController

- (NewsDataSource *) newsDataSource{
    if(!_newsDataSource) _newsDataSource = [NewsDataSource newsDataSource];
    return _newsDataSource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:false animated:true];
    [self.navigationItem setHidesBackButton:YES];
    [super setTitle:@"Your Groups"];
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

        [self.tableView reloadData];
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
    return self.newsDataSource.allGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"GroupCell";
    
    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NewsGroup *ng = (self.newsDataSource.allGroups)[indexPath.row];
    cell.textLabel.text = ng.title;
    return cell;
}
@end
