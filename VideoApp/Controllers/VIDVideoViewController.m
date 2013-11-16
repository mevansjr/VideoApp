//
//  VIDVideoViewController.m
//  VideoApp
//
//  Created by Mark Evans on 11/11/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import "VIDVideoViewController.h"
#import "ParseAPIFeedCall.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VIDVideoViewController ()
{
    MPMoviePlayerController *player;
}
@end

@implementation VIDVideoViewController

- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"\nInternet Connected: %@\nSize: %@ \nVersion: %@", [self getConnection], [self getSize], [self getVersion]);
    VIDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"PARAM: %@", appDelegate.param);
    if (appDelegate.param != nil) {
        [self queryParse:appDelegate.param];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.title = @"Video View";
    [videoV setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"video_placeholder.png"]]];
    [self performSelector:@selector(getInfo) withObject:nil afterDelay:2.0];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)handleBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup UI & Media Player

- (void)getInfo {
    NSLog(@"\nCount: %i \nDescription: %@", self.array.count, self.array.description);
    NSDictionary *dict = [[NSMutableDictionary alloc]init];
    dict = (NSMutableDictionary*)[self.array objectAtIndex:0];
    NSString *title = (NSString*)[dict objectForKey:@"title"];
    NSString *desc = (NSString*)[dict objectForKey:@"description"];
    dispatch_async(dispatch_get_main_queue(), ^{
        titleL.text = title;
        descL.text = desc;
    });
    
    PFFile *screenImageFile = (PFFile*)[dict objectForKey:@"screenshot"];
    NSURL *url = [NSURL URLWithString:screenImageFile.url];
    NSLog(@"URL String: %@ - URL: %@", screenImageFile.url, url);
    [screenImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                screenshotImageView.image = [UIImage imageWithData:data];
                [player.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"video_placeholder.png"]]];
            });
        }
    }];
    
    PFFile *videoFile = (PFFile*)[dict objectForKey:@"video"];
    NSURL *videoUrl = [NSURL URLWithString:videoFile.url];
    NSLog(@"VIDEO URL String: %@ - VIDEO URL: %@", videoFile.url, videoUrl);
    player = [[MPMoviePlayerController alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        player.movieSourceType = MPMovieSourceTypeStreaming;
        player.controlStyle = MPMovieControlStyleNone;
        [player setContentURL:videoUrl];
        [player.view setFrame: videoV.bounds];
        player.shouldAutoplay = YES;
        [player prepareToPlay];
        [videoV addSubview: player.view];
    });
    [self performSelector:@selector(addVideoControls) withObject:nil afterDelay:1.5];
    
}

- (void)addVideoControls {
    [player setControlStyle:MPMovieControlStyleDefault];
}

#pragma mark - API Call to Parse

- (void)queryParse:(NSString*)filter_id {
    self.array = [[NSMutableArray alloc]init];
    if ([self connected])
    {
        ParseAPIFeedCall *parseAPI = [[ParseAPIFeedCall alloc]init];
        self.array = (NSMutableArray*)[parseAPI getAPIArray:filter_id];
    } else {
        NSLog(@"NOT CONNECTED");
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Connection Problem" andMessage:@"Please check your connection."];
        [alertView addButtonWithTitle:@"Done" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            NSLog(@"Cancel Clicked");
        }];
        [alertView show];
    }
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
