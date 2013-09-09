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
    return self.allGroups.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tableIdentifier = @"selectGroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    if(indexPath.row < self.allGroups.count){
        NewsGroup *newsGroup = [self.allGroups objectAtIndex:indexPath.row];
        cell.textLabel.text = newsGroup.title;
    } else {
        cell.textLabel.text = NSLocalizedString(@"New group", nil);
    }
    return cell;
}
//ALERTVIEW START
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    NSString *text = [[alertView textFieldAtIndex:0] text];
    return text.length > 0;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSString *text = [[alertView textFieldAtIndex:0] text];
    if([title isEqualToString:NSLocalizedString(@"Ok",nil)]){
        [[NewsDataSource newsDataSource] addNewsSourceWithUrl:[self.feedToBeAdded objectForKey:@"url"] inNewGroupWithName:text];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Adding",nil) maskType:SVProgressHUDMaskTypeBlack];

    }
}
//ALERTVIEW END

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row < self.allGroups.count){
        NewsGroup *newsGroup = [self.allGroups objectAtIndex:indexPath.row];
        [[NewsDataSource newsDataSource] addNewsSourceWithUrl:[self.feedToBeAdded objectForKey:@"url"] inNewsGroup:newsGroup];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Adding",nil) maskType:SVProgressHUDMaskTypeBlack];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"New group", nil) message:NSLocalizedString(@"The name of the new group", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
}

- (void) addEnded:(NSNotification*) notification{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Added",nil)];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
