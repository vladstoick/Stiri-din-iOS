//
//  AddNewsSourceCategoriesViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 9/7/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "AddNewsSourceCategoriesViewController.h"
#import "AddNewsSourceCategoriesFeedsViewController.h"
#import "NewsDataSource.h"
@interface AddNewsSourceCategoriesViewController ()
@property (strong,nonatomic)  NSDictionary *allFeeds;
@end

@implementation AddNewsSourceCategoriesViewController

- (NSDictionary*) allFeeds{
    if(!_allFeeds) _allFeeds = [[NewsDataSource newsDataSource] allFeeds];
    return _allFeeds;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allFeeds.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tableIdentifier = @"categoriesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableIdentifier];
    }
    NSString *category = [[self.allFeeds allKeys] objectAtIndex:indexPath.row];
    NSArray *feedsForCategory = [self.allFeeds objectForKey:category];
    cell.textLabel.text = [category capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%u",feedsForCategory.count];
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"selectedCategory"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AddNewsSourceCategoriesFeedsViewController *destViewController = segue.destinationViewController;
        NSString *category = [[self.allFeeds allKeys] objectAtIndex:indexPath.row];
        destViewController.feeds = [self.allFeeds objectForKey:category];
        destViewController.categoryTitle = category;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
