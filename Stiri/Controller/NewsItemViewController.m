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
#import "TSMiniWebBrowser/TSMiniWebBrowser.h"
@interface NewsItemViewController ()
@property (nonatomic) BOOL isInOptimalMode;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextView *titleView;
@end

@implementation NewsItemViewController


- (NSString *) stylePaperize {
    NSString *beg = @"<meta name=\"viewport\" content=\"width=320px; initial-scale=1.0; minimum-scale=1.0;\"/><body style=\"font-family:HelveticaNeue\" style='width:300px' >";
    NSString *title = [NSString stringWithFormat:@"<div style=\"font-size:21px;font-weight:bold; \">%@</br></div><div align=\"justify\" style=\"font-size:16px;width: auto; \">",self.currentNewsItem.title];
    self.currentNewsItem.paperized = [self.currentNewsItem.paperized stringByReplacingOccurrencesOfString:@"<img " withString:@"<img style='width:305' "];
    NSString *end = @"</div></body>";
    NSString *begAndTitle = [beg stringByAppendingString:title];
    NSString *result = [[begAndTitle stringByAppendingString:self.currentNewsItem.paperized] stringByAppendingString:end];
    self.isInOptimalMode = YES;
    return result;
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
    [self.webView loadHTMLString:[self stylePaperize] baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.webView.frame = self.view.bounds;
    [self.webView sizeToFit];
    [self.webView.scrollView sizeThatFits:self.view.bounds.size];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
