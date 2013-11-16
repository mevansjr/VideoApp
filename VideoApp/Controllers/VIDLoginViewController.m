//
//  VIDLoginViewController.m
//  VideoApp
//
//  Created by Mark Evans on 11/12/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import "VIDLoginViewController.h"
#import "SVProgressHUD.h"

@interface VIDLoginViewController ()
{
    IBOutlet UITextField *u;
    IBOutlet UITextField *p;
    IBOutlet UITextField *e;
    IBOutlet UIButton *signupBtn;
    IBOutlet UIButton *loginBtn;
    UIAlertView *confirm_noncurrent;
    UIAlertView *confirm_current;
}
@end

@implementation VIDLoginViewController

- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [u setDelegate:self];
    [p setDelegate:self];
    [e setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Textfield Delegate Protocols

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (u.text.length > 0 && p.text.length > 0 && e.text.length == 0) {
        [self login:nil];
        return YES;
    } else if (u.text.length > 0 && p.text.length > 0 && e.text.length > 0) {
        [self signup:nil];
        return YES;
    } else if (e.text.length > 0 && u.text.length == 0 && p.text.length == 0) {
        if([self validateEmail:e.text]) {
            [self forgot:nil];
            return YES;
        } else {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Check Email" andMessage:@"Email is not Valid."];
            [alertView addButtonWithTitle:@"Done"
                                     type:SIAlertViewButtonTypeDestructive
                                  handler:^(SIAlertView *alertView) {
                                      NSLog(@"User Validation Error -- Email");
                                  }];
            [alertView show];
            return NO;
        }
    } else {
        return YES;
    }
    return NO;
}

#pragma mark - Validate/Login/Signup/Close/Keyboard/Forgot

- (BOOL)validateTextLogin {
    if (u.text.length > 0 && p.text.length > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)validateTextSignup {
    if (u.text.length > 0 && p.text.length > 0 && e.text.length > 0) {
        return YES;
    }
    return NO;
}

-(BOOL)validateEmail:(NSString*)emailString {
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)login:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userLogged_yes = @"yes";
    NSString *userLogged_no = @"no";
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [PFUser logInWithUsernameInBackground:currentUser.username password:currentUser.password block:^(PFUser *user, NSError *error) {
            if (!user) {
                [defaults setObject:userLogged_yes forKey:@"logged"];
                [defaults synchronize];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"User Already Logged User in!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
                [alert show];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    } else {
        if ([self validateTextLogin]) {
            [PFUser logInWithUsernameInBackground:u.text password:p.text block:^(PFUser *user, NSError *error) {
                if (!user) {
                    [defaults setObject:userLogged_no forKey:@"logged"];
                    [defaults synchronize];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Username and Password are incorrect." delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    [defaults setObject:userLogged_yes forKey:@"logged"];
                    [defaults synchronize];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Check Validation!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (IBAction)signup:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userLogged_yes = @"yes";
    NSString *userLogged_no = @"no";
    PFUser *currentUser = [PFUser currentUser];
    if ([currentUser.username isEqualToString:u.text]) {
        [defaults setObject:userLogged_yes forKey:@"logged"];
        [defaults synchronize];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"User Already Exist!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }
    if (currentUser) {
        [PFUser logInWithUsernameInBackground:currentUser.username password:currentUser.password block:^(PFUser *user, NSError *error) {
            if (!user) {
                [defaults setObject:userLogged_no forKey:@"logged"];
                [defaults synchronize];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Problem logging User in!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
                [alert show];
            } else {
                [defaults setObject:userLogged_yes forKey:@"logged"];
                [defaults synchronize];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    } else {
        if ([self validateTextSignup]) {
            PFUser *user = [PFUser user];
            user.username = u.text;
            user.password = p.text;
            user.email = e.text;
            [user setObject:@"no" forKey:@"canUpload"];
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [defaults setObject:userLogged_yes forKey:@"logged"];
                    [defaults synchronize];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [defaults setObject:userLogged_no forKey:@"logged"];
                    [defaults synchronize];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Problem logging User in!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
                    [alert show];
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"ERROR: %@", errorString);
                }
            }];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Check Validation!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)removeKeyboard:(id)sender {
    [u resignFirstResponder];
    [p resignFirstResponder];
    [e resignFirstResponder];
}

- (IBAction)forgot:(id)sender {
    if (e.text.length > 0) {
        confirm_noncurrent = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to RESET your password?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirm_noncurrent show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Enter your Email!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == confirm_noncurrent) {
        if (!buttonIndex == 0) {
            [PFUser requestPasswordResetForEmailInBackground:e.text];
        }
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
