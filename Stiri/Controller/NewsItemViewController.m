//
//  NewsItemViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/14/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "NewsItemViewController.h"
#import "NewsSource.h"
#import "NewsDataSource.h"
@interface NewsItemViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (readonly, nonatomic) NewsItem *currentNewsItem;
@property (readonly, nonatomic) NewsSource *newsSource;
@end

@implementation NewsItemViewController

- (NewsItem *) currentNewsItem{
    return [[NewsDataSource newsDataSource] getNewsItemWithUrl:self.currentNewsItemUrl fromSourceWithId:self.sourceId];
}

- (NewsSource*) newsSource{
    return [[NewsDataSource newsDataSource] getNewsSourceWithId:self.sourceId];
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
    self.title = self.newsSource.title;
    [self.webView loadHTMLString:self.currentNewsItem.paperized baseURL:nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
