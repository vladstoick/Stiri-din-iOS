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
@interface PageNewsItemsViewController () <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NewsSource *newsSource;
@end

@implementation PageNewsItemsViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NewsSource*) newsSource{
    if(!_newsSource)
        _newsSource = [[NewsDataSource newsDataSource] getNewsSourceWithId:self.sourceId];
    return _newsSource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    NewsItemViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NewsItemViewController *currentViewController = (NewsItemViewController*) viewController;
    if(currentViewController.index == self.newsSource.news.count -1 ){
        return nil;
    }
    return [self viewControllerAtIndex:currentViewController.index+1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NewsItemViewController *currentViewController = (NewsItemViewController*) viewController;
    if(currentViewController.index == 0){
        return nil;
    }
    return [self viewControllerAtIndex:currentViewController.index - 1 ];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return self.newsSource.news.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

- (NewsItemViewController*) viewControllerAtIndex:(NSUInteger) index{
    NewsItemViewController *newsItemViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"newsItemViewController"];
    NSArray *news = [self.newsSource.news allObjects];
    newsItemViewController.index = index;
    newsItemViewController.currentNewsItem = [news objectAtIndex:index];
    return newsItemViewController;
}
@end
