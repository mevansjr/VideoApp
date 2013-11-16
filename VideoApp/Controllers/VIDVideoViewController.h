//
//  VIDVideoViewController.h
//  VideoApp
//
//  Created by Mark Evans on 11/11/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VIDVideoViewController : UIViewController
{
    IBOutlet UILabel *titleL;
    IBOutlet UILabel *descL;
    IBOutlet UIImageView *screenshotImageView;
    IBOutlet UIView *videoV;
}
- (void)queryParse:(NSString*)filter_id;
@property (nonatomic) NSMutableArray *array;

@end
