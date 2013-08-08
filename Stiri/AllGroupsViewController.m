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
@interface AllGroupsViewController ()

@end

@implementation AllGroupsViewController{
    NewsDataSource *newsDataSource;
    int userId;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    [super setTitle:@"Your Groups"];
    [SVProgressHUD show];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userId = [defaults integerForKey:@"user_id"];
    newsDataSource.userId = userId;
    NSString *urlString = [NSString stringWithFormat:@"http://stiriromania.eu01.aws.af.cm/user/%d",userId];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: [responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options: NSJSONReadingMutableContainers
                                                                         error: nil];
        [newsDataSource loadData:jsonDictionary];
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *simpleTableIdentifier = @"GroupCell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
//    }
//    
//    cell.textLabel.text = [allGroups objectAtIndex:indexPath.row];
//    return cell;
}
@end
