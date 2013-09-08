//
//  PageNewsItemsViewController.h
//  Stiri
//
//  Created by Vlad Stoica on 8/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsSource.h"
#import "NewsItem.h"
#import <Social/Social.h>
@interface PageNewsItemsViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
- (IBAction)openInBrowser:(id)sender;
- (IBAction)share:(id)sender;
@property (nonatomic) NSInteger newsIndex;
@property (strong, nonatomic) NSArray* news;
@end
