//
//  VIDMainViewController.h
//  VideoApp
//
//  Created by Mark Evans on 11/11/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SSPullToRefresh.h"

@interface VIDMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SSPullToRefreshViewDelegate>
{
    IBOutlet UITableView *theTableView;
    SSPullToRefreshView *pullToRefreshView;
}
@property (nonatomic) NSMutableArray *array;
@property (nonatomic, copy) void(^onShowMenuButtonClicked)(void);
- (void)setOnShowMenuButtonClicked:(void (^)(void))onShowMenuButtonClicked;

@end
