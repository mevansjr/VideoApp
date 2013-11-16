//
//  VIDLoginViewController.h
//  VideoApp
//
//  Created by Mark Evans on 11/12/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VIDLoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)close:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;
- (IBAction)removeKeyboard:(id)sender;
- (IBAction)forgot:(id)sender;

@end
