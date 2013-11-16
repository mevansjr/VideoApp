//
//  ParseAPIFeedCall.h
//  VideoApp
//
//  Created by Mark Evans on 11/11/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseAPIFeedCall : NSObject

@property (nonatomic) NSMutableArray *array;

- (NSMutableArray*)getAPIArray;
- (NSMutableArray*)getAPIArray:(NSString*)filter_id;

@end
