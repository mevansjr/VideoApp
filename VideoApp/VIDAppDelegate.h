//
//  VIDAppDelegate.h
//  VideoApp
//
//  Created by Mark Evans on 11/11/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VIDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) NSString *param;

@property (strong, nonatomic) NSString *logged;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end
