//
//  ParseAPIFeedCall.m
//  VideoApp
//
//  Created by Mark Evans on 11/11/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import "ParseAPIFeedCall.h"
#import <CoreData/CoreData.h>

@implementation ParseAPIFeedCall

- (NSMutableArray*)getAPIArray {
    self.array = [[NSMutableArray alloc]init];    
    PFQuery *query = [PFQuery queryWithClassName:@"Feed"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %d properties.", objects.count);
            if (objects.count <= 0) {
                NSString *msg = [NSString stringWithFormat:@"No Videos. Feed is empty!"];
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Empty" andMessage:msg];
                [alertView addButtonWithTitle:@"Done" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
                    NSLog(@"Cancel Clicked");
                }];
                [alertView show];
            }
            for (PFObject *object in objects) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                dict = (NSMutableDictionary*) @{
                                                @"video": [object objectForKey:@"video"],
                                                @"screenshot": [object objectForKey:@"screenshot"],
                                                @"title": [object objectForKey:@"title"],
                                                @"description": [object objectForKey:@"description"],
                                                @"theId": [object objectId]
                                                };
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    return self.array;
}

- (NSMutableArray*)getAPIArray:(NSString*)filter_id {
    self.array = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"Feed"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"objectId" equalTo:filter_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %d properties.", objects.count);
            if (objects.count <= 0) {
                NSString *msg = [NSString stringWithFormat:@"No Videos with that ID."];
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Empty" andMessage:msg];
                [alertView addButtonWithTitle:@"Done" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
                    NSLog(@"Cancel Clicked");
                }];
                [alertView show];
            }
            for (PFObject *object in objects) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                dict = (NSMutableDictionary*) @{
                                                @"video": [object objectForKey:@"video"],
                                                @"screenshot": [object objectForKey:@"screenshot"],
                                                @"title": [object objectForKey:@"title"],
                                                @"description": [object objectForKey:@"description"],
                                                @"theId": [object objectId]
                                                };
                [self.array addObject:dict];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    return self.array;
}

@end
