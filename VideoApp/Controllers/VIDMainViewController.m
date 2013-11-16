//
//  VIDMainViewController.m
//  VideoApp
//
//  Created by Mark Evans on 11/11/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import "VIDMainViewController.h"
#import "VIDVideoViewController.h"
#import "VIDLoginViewController.h"
#import "ParseAPIFeedCall.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NVSlideMenuController.h"
#import "SVProgressHUD.h"
#import "NXOAuth2Request.h"
#import "NXOAuth2AccountStore.h"

@interface VIDMainViewController ()
{
}

@end

@implementation VIDMainViewController

- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"\nInternet Connected: %@\nSize: %@ \nVersion: %@", [self getConnection], [self getSize], [self getVersion]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewDataCall) name:@"DoReload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHome) name:@"DoHome" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doProfile) name:@"DoProfile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doLogout) name:@"DoLogout" object:nil];
    [theTableView reloadData];
    [self performSelector:@selector(reloadTableViewData) withObject:nil afterDelay:2];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *logged_in = (NSString*)[defaults objectForKey:@"logged"];
    if (![logged_in isEqualToString:@"yes"]) {
        [self performSegueWithIdentifier:@"com.markevansjr.loginView" sender:self];
    }
    
    //Parse Call
    if (self.array.count <= 0 && self.array == nil) {
        [self queryParse];
        [theTableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.title = @"VideoApp";
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeBlack];
    
    //Set Buttons for NavBar
//    UIBarButtonItem *logoutBtn = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(doLogout)];
//    self.navigationItem.rightBarButtonItem = logoutBtn;
    UIBarButtonItem *profileBtn = [[UIBarButtonItem alloc]initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(showMenu:)];
    self.navigationItem.leftBarButtonItem = profileBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - SSPullToRefresh

//- (BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view {
//    return YES;
//}
//
//- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
//    [self reloadPullToRefresh];
//}
//
//- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view {
//    
//}
//
//- (NSDate *)pullToRefreshViewLastUpdatedAt:(SSPullToRefreshView *)view {
//
//}
//
//- (void)pullToRefreshView:(SSPullToRefreshView *)view didUpdateContentInset:(UIEdgeInsets)contentInset {
//    
//}

#pragma mark - NavigationBar

- (void)doHome {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    [s instantiateInitialViewController];
}

- (void)doProfile {
    [self performSegueWithIdentifier:@"com.markevansjr.push_profile" sender:self];
}

- (void)doLogout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userLogged_no = @"no";
    [defaults setObject:userLogged_no forKey:@"logged"];
    [defaults synchronize];
    [PFUser logOut];
    [self performSegueWithIdentifier:@"com.markevansjr.loginView" sender:self];
}

#pragma mark - Table View Delegate Protocols

- (void)reloadTableViewData {
    [theTableView reloadData];
}

- (void)reloadTableViewDataCall {
    [self queryParse];
    [theTableView reloadData];
    [self viewDidLoad];
}

- (void)reloadPullToRefresh {
    double delayInSeconds = 2.0;
    dispatch_time_t popTime =  dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(popTime, backgroundQueue, ^(void){
        [self queryParse];
        dispatch_async(dispatch_get_main_queue(), ^{
            [pullToRefreshView finishLoading];
            [theTableView reloadData];
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.array.count > 0) {
        return self.array.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict = (NSMutableDictionary*)[self.array objectAtIndex:indexPath.row];
    NSString *title = (NSString*)[dict objectForKey:@"title"];
    NSString *description = (NSString*)[dict objectForKey:@"description"];
    PFFile *imageFile = (PFFile*)[dict objectForKey:@"screenshot"];
    
    NSString *identifer = @"com.markevansjr.tableview_cell";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    if (cell != nil) {
        cell.imageView.image = [UIImage imageNamed:@"video_placeholder.png"];
        cell.textLabel.text = @"Loading...";
        cell.detailTextLabel.text = @"Please Stand by.";
        if (title != nil) {
            cell.textLabel.text = title;
        }
        if (description != nil) {
            cell.detailTextLabel.text = description;
        }
        if (imageFile != nil) {
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (data != nil) {
                    cell.imageView.image = [UIImage imageWithData:data];
                }
            }];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict = (NSMutableDictionary*)[self.array objectAtIndex:indexPath.row];
    NSString *theId = (NSString*)[dict objectForKey:@"theId"];
    VIDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.param = theId;
    [self performSegueWithIdentifier:@"com.markevansjr.video_view" sender:self];
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Show menu

- (IBAction)showMenu:(id)sender
{
    if (self.onShowMenuButtonClicked)
        self.onShowMenuButtonClicked();
    else
        [self.slideMenuController openMenuAnimated:YES completion:nil];
}

#pragma mark - API Call to Parse

- (void)queryParse {
    self.array = [[NSMutableArray alloc]init];
    if ([self connected])
    {
        ParseAPIFeedCall *parseAPI = [[ParseAPIFeedCall alloc]init];
        self.array = (NSMutableArray*)[parseAPI getAPIArray];
        [theTableView reloadData];
    } else {
        NSLog(@"NOT CONNECTED");
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Connection Problem" andMessage:@"Please check your connection."];
        [alertView addButtonWithTitle:@"Done" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            NSLog(@"Cancel Clicked");
        }];
        [alertView show];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

#pragma mark - System Checks

- (NSString*)getConnection {
    NSString *isConnected;
    if ([self connected]){
        isConnected = @"Yes";
    } else {
        isConnected = @"No";
    }
    return isConnected;
}

- (NSString*)getVersion {
    NSString *version;
    if (IS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
       version = @"iOS 7 or Greater";
    } else if (IS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
        version = @"iOS 6 or Greater";
    } else if (IS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")){
        version = @"iOS 5 or Greater";
    } else {
        version = @"iOS 4 and Below";
    }
    return version;
}

- (NSString*)getSize {
    NSString *size;
    if (IS_IPHONE5){
        size = @"iPhone 5 Retina Screen";
    } else if (IS_RETINA && !IS_IPHONE5){
        size = @"iPhone 3.5 Retina Screen";
    } else {
        size = @"iPhone 3.5 Non-Retina Screen";
    }
    return size;
}

@end
