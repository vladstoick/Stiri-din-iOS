//
//  AddNewsSourceCategoriesFeedsViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 9/7/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "AddNewsSourceCategoriesFeedsViewController.h"
#import "AddNewsSourceSelectGroupViewController.h"
#import "NewsDataSource.h"
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
    NSNumber *subscribers = [feed objectForKey:@"subscribers"];
    NSString *subscribersString = [NSString stringWithFormat:@"%@ ",subscribers];
    if([subscribers isEqual: @1]){
        subscribersString = NSLocalizedString(@"one subscriber", nil);
    } else {
        subscribersString = [subscribersString stringByAppendingString:NSLocalizedString(@"subscribers", nil)];
    }
    cell.detailTextLabel.text =  subscribersString;
    return cell;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"selectedAFeed"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *feedToBeAdded = [self.feeds objectAtIndex:indexPath.row];
        if([[NewsDataSource newsDataSource] hasNewsSourceWithID:[feedToBeAdded valueForKey:@"id"]]==YES){
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You already have that news source", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil]show];
            return NO;
        }
        
    }
    return YES;
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
