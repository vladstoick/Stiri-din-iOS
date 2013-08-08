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
@property (assign, nonatomic) int userId;

@end

@implementation AllGroupsViewController
@synthesize tableView;
@synthesize newsDataSource;
@synthesize userId;

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    [super setTitle:@"Your Groups"];
	self.newsDataSource = [[NewsDataSource alloc] init];
    [SVProgressHUD show];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userId = [defaults integerForKey:@"user_id"];
    newsDataSource.userId = userId;
    self.userId = [defaults integerForKey:@"user_id"];
    self.newsDataSource.userId = userId;
    NSString *urlString = [NSString stringWithFormat:@"http://stiriromania.eu01.aws.af.cm/user/%d",userId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: [responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options: NSJSONReadingMutableContainers
                                                                         error: nil];
        [newsDataSource loadData:jsonDictionary];
        [SVProgressHUD dismiss];
        [tableView reloadData];
        [self.newsDataSource loadData:jsonDictionary];
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
    return newsDataSource.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"GroupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NewsGroup *ng = (newsDataSource.groups)[indexPath.row];
    cell.textLabel.text = ng.title;
    return cell;
}
@end
