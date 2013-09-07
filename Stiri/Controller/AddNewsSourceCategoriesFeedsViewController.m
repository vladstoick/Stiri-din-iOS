//
//  AddNewsSourceCategoriesFeedsViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 9/7/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "AddNewsSourceCategoriesFeedsViewController.h"
#import "AddNewsSourceSelectGroupViewController.h"
@interface AddNewsSourceCategoriesFeedsViewController ()

@end

@implementation AddNewsSourceCategoriesFeedsViewController

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
    self.title = [self.categoryTitle capitalizedString];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tableIdentifier = @"feedCategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if(cell == nil ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableIdentifier];
    }
    NSDictionary *feed = [self.feeds objectAtIndex:indexPath.row];
    cell.textLabel.text = [feed objectForKey:@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[feed objectForKey:@"subscribers"]];
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"selectedAFeed"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AddNewsSourceSelectGroupViewController *destViewController = segue.destinationViewController;
        destViewController.feedToBeAdded = [self.feeds objectAtIndex:indexPath.row];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
