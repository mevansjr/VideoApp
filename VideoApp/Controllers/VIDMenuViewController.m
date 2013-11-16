//
//  VIDMenuViewController.m
//  VideoApp
//
//  Created by Mark Evans on 11/13/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import "VIDMenuViewController.h"
#import "NVSlideMenuController.h"

#define NUMBER_OF_SECTIONS        2
#define NUMBER_OF_ROWS                2

@interface VIDMenuViewController ()

- (void)togglePanGestureEnabled:(UIBarButtonItem *)sender;
- (void)toggleSlideDirection:(UIBarButtonItem *)sender;

@end

@implementation VIDMenuViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.title = NSLocalizedString(@"Menu", nil);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_SECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return NUMBER_OF_ROWS;
    } else if (section == 1) {
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0)
        cell.textLabel.text = NSLocalizedString(@"Home", nil);
    else if (indexPath.section == 0 && indexPath.row == 1)
        cell.textLabel.text = NSLocalizedString(@"Profile", nil);
    else if (indexPath.section == 0 && indexPath.row == 2)
        cell.textLabel.text = NSLocalizedString(@"Settings", nil);
    else if (indexPath.section == 1 && indexPath.row == 0)
        cell.textLabel.text = NSLocalizedString(@"Log Out", nil);
    else
        cell.textLabel.text = @"";
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        //Go to HomeView
        NSLog(@"MENU: HomeView called.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DoHome" object:nil userInfo:nil];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        //Go to ProfileView
        NSLog(@"MENU: Profle called.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DoProfile" object:nil userInfo:nil];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        //Go to SettingsView
        NSLog(@"MENU: Settings not set yet.");
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"DoReload" object:nil userInfo:nil];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        //Go to Log Out
        NSLog(@"MENU: Logout called.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DoLogout" object:nil userInfo:nil];
    } else {
        //
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.slideMenuController closeMenuAnimated:YES completion:nil];
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - Toggle pan gesture enabled

- (void)togglePanGestureEnabled:(UIBarButtonItem *)sender {
    self.slideMenuController.panGestureEnabled = !self.slideMenuController.panGestureEnabled;
    sender.title = self.slideMenuController.panGestureEnabled ? NSLocalizedString(@"Pan Enabled", nil) : NSLocalizedString(@"Pan Disabled", nil);
}


#pragma mark - Toggle slide direction

- (void)toggleSlideDirection:(UIBarButtonItem *)sender {
    if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
    {
        [self.slideMenuController setSlideDirection:NVSlideMenuControllerSlideFromRightToLeft animated:YES];
        sender.title = NSLocalizedString(@"R->L", nil);
    }
    else if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromRightToLeft)
    {
        [self.slideMenuController setSlideDirection:NVSlideMenuControllerSlideFromLeftToRight animated:YES];
        sender.title = NSLocalizedString(@"L->R", nil);
    }
}

@end
