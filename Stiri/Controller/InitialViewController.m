//
//  InitialViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/13/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "InitialViewController.h"
#import "MMDrawerController.h"
@interface InitialViewController ()

@end

@implementation InitialViewController

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
    UIViewController *topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Main"];
    UIViewController *menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    self.centerViewController = topViewController;
    self.leftDrawerViewController = menuViewController;
    self.openDrawerGestureModeMask = MMOpenDrawerGestureModeBezelPanningCenterView;
    self.closeDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
