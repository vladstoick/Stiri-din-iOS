//
//  LoginViewController.m
//  Stiri
//
//  Created by Vlad Stoica on 8/7/13.
//  Copyright (c) 2013 Stoica Vlad. All rights reserved.
//

#import "LoginViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

static NSString * const kClientId = @"976584719831.apps.googleusercontent.com";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionStateChanged:)
                                                 name:FB_SESSION_CHANGE_NOTIFICATION
                                               object:nil];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mm_drawerController.shouldStretchDrawer = NO;
    self.mm_drawerController.openDrawerGestureModeMask = MMDrawerOpenCenterInteractionModeNone;
    self.view.backgroundColor =    [UIColor colorWithPatternImage:[UIImage imageNamed:@"squairy_light.png"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.navigationItem.hidesBackButton = YES;
    if([defaults integerForKey:@"user_id"]){
        [self performSegueWithIdentifier:@"loginSuccesfulSegue" sender:self];
    } else{
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.clientID = kClientId;
        signIn.scopes = @[kGTLAuthScopePlusLogin];
        signIn.shouldFetchGoogleUserID = true;
        signIn.shouldFetchGoogleUserEmail = true;
        signIn.delegate = self;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//GOOGLE +

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if(!error){
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"Logging in", nil)]];
        NSString *userId = [GPPSignIn sharedInstance].userID;
        NSString *token = [auth.parameters valueForKey:@"id_token"];
        NSLog(@"Received error %@ and auth object %@",
              [GPPSignIn sharedInstance].userID , auth);
        [self authWithServerToken:token andUserId:userId withType:@"gp"];
    }
    
}

//FACEBOOK

- (IBAction)loginWithFacebook:(id)sender {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openActiveSessionWithLoginUI:YES];
}
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (FBSession.activeSession.isOpen && ![defaults integerForKey:@"user_id"]) {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"Logging in", nil)]];

        [[NSNotificationCenter defaultCenter] removeObserver:self];
        NSString *token = (NSString*)FBSession.activeSession.accessTokenData;
        [[FBRequest requestForMe]
         startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
         {
             // Did everything come back okay with no errors?
             if (!error && result)
             {
                 NSString *userID = result.id;
                 
                 [self authWithServerToken:token andUserId:userID withType:@"fb"];
             }
         }];
        NSLog(@"%@",token);
        
    }
}


//server communication

-(void) authWithServerToken: (NSString*) token andUserId: (NSString*) userId withType:(NSString*) type{
    NSString *urlString =[NSString stringWithFormat:@"http://37.139.26.80/"];
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = @{@"account": userId,
                             @"token": token,
                             @"type": type};
    [httpClient postPath:@"/user/login" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: [responseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options: NSJSONReadingMutableContainers
                                                                         error: nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *userServerId = [jsonDictionary valueForKey:@"id"];
        NSString *key = [jsonDictionary valueForKey:@"key"];
        if([userServerId isEqual: @0]){
            return;
        }
        [defaults setValue:key forKey:@"key"];
        [defaults setValue:userServerId forKey:@"user_id"];
        NSLog(@"Succesfully logged in user with id : %@ ; Auth Token : %@" , userServerId, key);
        [SVProgressHUD dismiss];
        [self performSegueWithIdentifier:@"loginSuccesfulSegue" sender:self];
        NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error);
    }];
}
@end





