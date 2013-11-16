//
//  VIDAppDelegate.m
//  VideoApp
//
//  Created by Mark Evans on 11/11/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import "VIDAppDelegate.h"
#import "VIDMenuViewController.h"
#import <Parse/Parse.h>
#import "NVSlideMenuController.h"
#import "TestFlight.h"
#import "NXOAuth2AccountStore.h"
#import <CoreData/CoreData.h>

@implementation VIDAppDelegate

@synthesize managedObjectContext;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"V4lL3xO9OcOXzz4qpQmjCqSSwCcJwlUR8OY37sQy"
                  clientKey:@"Pb5NWs3CFo0fS8Dvi5xxxKDxh3iGq1rNY820KYJL"];
    [TestFlight takeOff:@"ee05770a-ff63-4561-9406-7ee0506fea77"];
    
    VIDMenuViewController *menuVC = [[VIDMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *menuNavigationController = [[UINavigationController alloc] initWithRootViewController:menuVC];
    
    UIStoryboard *appropriateStoryBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    NVSlideMenuController *slideMenuVC = [[NVSlideMenuController alloc] initWithMenuViewController:menuNavigationController andContentViewController:[appropriateStoryBoard instantiateInitialViewController]];
    
    self.window.rootViewController = slideMenuVC;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
