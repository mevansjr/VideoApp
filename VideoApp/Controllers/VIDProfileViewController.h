//
//  VIDProfileViewController.h
//  VideoApp
//
//  Created by Mark Evans on 11/12/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface VIDProfileViewController : UIViewController <UINavigationControllerDelegate, UIVideoEditorControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

- (IBAction)openVideoPickerView:(id)sender;

@end
