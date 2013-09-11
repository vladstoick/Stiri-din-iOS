//
//  AppDelegate.m
//  Stiri
//
//  Created by Stoica Vlad on 7/24/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreData+MagicalRecord.h"
#import <GooglePlus/GooglePlus.h>
#import <FacebookSDK/FacebookSDK.h>
#import <NewRelicAgent/NewRelicAgent.h>
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#import <CoreData/CoreData.h>
@implementation AppDelegate

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NewRelicAgent startWithApplicationToken:@"AAda1a6278e5ef8e4349079aa07d6b5039aaa395a0"];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"data.sqlite"];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
        [[UITabBar appearance] setTintColor:[UIColor blackColor]];
        [[UIToolbar appearance] setTintColor:[UIColor blackColor]];
    }
    return YES;
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}


- (void)applicationDidEnterBackground:(UIApplication *)application{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [FBSession.activeSession close];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    NSString *urlString = [url absoluteString];
    if([urlString hasPrefix:@"fb"]){
        return [FBSession.activeSession handleOpenURL:url];
    } else{
        return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
    }
}

//FACEBOOK LOGIN

- (void)openActiveSessionWithLoginUI:(BOOL)allowLoginUI
{
    NSLog(@"openActiveSessionWithLoginUI: %d in NHOCAppDelegate", allowLoginUI);
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session state:state error:error];
                                  }];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    NSLog(@"sessionStateChanged:state:error: in NHOCAppDelegate");
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                //
                // We have a valid session
                //
                NSLog(@"FBSessionStateOpen");
            }
            break;
            
        case FBSessionStateClosed:
            NSLog(@"FBSessionStateClosed");
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
            
        case FBSessionStateClosedLoginFailed:
            NSLog(@"FBSessionStateClosedLoginFailed");
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
            
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FB_SESSION_CHANGE_NOTIFICATION object:session];
    
    if (error) {
        NSLog(@"Some nasty error! <o> (Tip: check if the app is allowed in Settings / Facebook / Allow these apps...)");

    }
}

@end
