//
//  AddNewsSourceSelectGroupViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 9/7/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "AddNewsSourceSelectGroupViewController.h"
#import "NewsDataSource.h"
#import "SVProgressHUD.h"
#define ADD_ENDED @"add_ended"
@interface AddNewsSourceSelectGroupViewController ()
@property (strong, nonatomic) NSArray *allGroups;
@end

@implementation AddNewsSourceSelectGroupViewController

- (NSArray*) allGroups{
    if(!_allGroups) _allGroups = [[NewsDataSource newsDataSource] allGroups];
    return _allGroups;
}

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
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEnded:) name:ADD_ENDED object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tableIdentifier = @"selectGroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    NewsGroup *newsGroup = [self.allGroups objectAtIndex:indexPath.row];
    cell.textLabel.text = newsGroup.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsGroup *newsGroup = [self.allGroups objectAtIndex:indexPath.row];
    [[NewsDataSource newsDataSource] addNewsSourceWithUrl:[self.feedToBeAdded objectForKey:@"url"] inNewsGroup:newsGroup];
    [SVProgressHUD showWithStatus:@"Adding" maskType:SVProgressHUDMaskTypeBlack];
}

- (void) addEnded:(NSNotification*) notification{
    [SVProgressHUD showSuccessWithStatus:@"Succes"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
