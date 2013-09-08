//
//  PageNewsItemsViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "PageNewsItemsViewController.h"
#import "NewsItemViewController.h"
#import "NewsDataSource.h"
#import "TSMiniWebBrowser.h"
@interface PageNewsItemsViewController () 
@property(strong, nonatomic) UIPageViewController *pageController;
@end

@implementation PageNewsItemsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.pageController = [[UIPageViewController alloc]
            initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                            options:nil];

    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    CGRect framePC = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+36);
    [[self.pageController view] setFrame:framePC];
    [[NewsDataSource newsDataSource] makeNewsItemRead:[self newsItemAtIndex:self.newsIndex]];
    NewsItemViewController *initialViewController = [self viewControllerAtIndex:self.newsIndex];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];

    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];

    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed == YES) {
        NewsItemViewController *currentViewController = (self.pageController.viewControllers)[0];
        NSInteger index = currentViewController.index;
        [[NewsDataSource newsDataSource] makeNewsItemRead:[self newsItemAtIndex:(NSUInteger) index]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    NewsItemViewController *currentViewController = (NewsItemViewController *) viewController;
    if (currentViewController.index == self.news.count - 1) {
        return nil;
    }
    return [self viewControllerAtIndex:currentViewController.index + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    NewsItemViewController *currentViewController = (NewsItemViewController *) viewController;
    if (currentViewController.index == 0) {
        return nil;
    }
    return [self viewControllerAtIndex:currentViewController.index - 1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return self.news.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return self.newsIndex;
}

- (NewsItem *)newsItemAtIndex:(NSInteger)index {
    NSArray *news = self.news;
    return [news objectAtIndex:(NSUInteger)index];
}

- (NewsItemViewController *)viewControllerAtIndex:(NSInteger)index {
    NewsItemViewController *newsItemViewController;
    newsItemViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"newsItemViewController"];
    newsItemViewController.index = index;
    newsItemViewController.currentNewsItem = [self newsItemAtIndex:index];
    return newsItemViewController;
}

//BUTTONS

- (IBAction)share:(id)sender {
    NewsItemViewController *currentViewController = (self.pageController.viewControllers)[0];
    NSArray *activity_elements = @[[NSString stringWithFormat:@"%@ via News from", currentViewController.currentNewsItem.url]];
    UIActivityViewController *uiActivityViewController = [[UIActivityViewController alloc] initWithActivityItems:activity_elements applicationActivities:nil];
    [self presentViewController:uiActivityViewController animated:YES completion:nil];
}
- (IBAction)openInBrowser:(id)sender {
    NewsItemViewController *currentViewController = (self.pageController.viewControllers)[0];
    NSURL *url = [NSURL URLWithString:currentViewController.currentNewsItem.url];
    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:url];
    webBrowser.barStyle = UIBarStyleBlack;
    [self.navigationController pushViewController:webBrowser animated:YES];   
}

@end
