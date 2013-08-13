//
//  NewsSourceViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsSourceViewController.h"
#import "NewsGroup.h"
#import "NewsDataSource.h"
@interface NewsSourceViewController ()
@property (weak, nonatomic) IBOutlet UITableView *newsSourceTableView;
@property (strong, nonatomic) NewsDataSource *newsDataSource;
@property (strong, nonatomic) NewsGroup *newsGroup;
@end

@implementation NewsSourceViewController

- (NewsDataSource*) newsDataSource{
    if(!_newsDataSource) _newsDataSource = [NewsDataSource newsDataSource];
    return _newsDataSource;
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
    self.newsGroup = [self.newsDataSource getGroupWithId:self.groupId];
    self.title = self.newsGroup.title;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
