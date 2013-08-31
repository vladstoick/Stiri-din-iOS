//
//  AppDelegate.h
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsDataSource.h"
#define FB_SESSION_CHANGE_NOTIFICATION @"FBSessionChangeNotification"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
- (void) openActiveSessionWithLoginUI:(BOOL)allowLoginUI;
@end
