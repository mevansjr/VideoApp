//
//  VIDProfileViewController.m
//  VideoApp
//
//  Created by Mark Evans on 11/12/13.
//  Copyright (c) 2013 Mark Evans Jr. All rights reserved.
//

#import "VIDProfileViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SVProgressHUD.h"

@interface VIDProfileViewController ()
{
    IBOutlet UILabel *userName;
    IBOutlet UILabel *userEmail;
    IBOutlet UIImageView *profileImg;
    IBOutlet UIButton *uploadVideoBtn;
    UIImagePickerController *pickerView;
    PFFile *videoFile;
    PFFile *imageFile;
    UIAlertView *confirm;
    PFFile *profileImageFile;
    NSData *theData;
    NSData *imageData2;
    UIImage *profile;
    UIImagePickerController *pickerView2;
    NSString *canUploadStr;
}
@end

@implementation VIDProfileViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHome) name:@"DoHome" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileImage) name:@"DoProfileImageUpdate" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *logged_in = (NSString*)[defaults objectForKey:@"logged"];
    if (![logged_in isEqualToString:@"yes"]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.title = @"Profile";
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        userName.text = currentUser.username;
        userEmail.text = currentUser.email;
        canUploadStr = (NSString*)[currentUser objectForKey:@"canUpload"];
        if ([canUploadStr isEqualToString:@"no"]) {
            [uploadVideoBtn setHidden:YES];
        } else {
            [uploadVideoBtn setHidden:NO];
        }
    }

    UIImage *img = [UIImage imageNamed:@"profile_image.png"];
    NSData *defaultImageData = UIImagePNGRepresentation(img);
    [self uploadProfileImage:defaultImageData];
    [self getImage];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)doHome {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)handleBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - PickerView Delegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (picker == pickerView2) {
        if (info == nil){
            theData = nil;
        } else {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            theData = UIImageJPEGRepresentation(image, 0.05f);
            [self uploadProfileImage:theData];
            [profileImg setImage:image];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.beginTime = CACurrentMediaTime()+.25;
            animation.duration = .25;
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat:1.0f];
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeBoth;
            animation.additive = NO;
            [profileImg.layer addAnimation:animation forKey:@"opacityIN"];
            [self performUpload];
        }
        [self dismissViewControllerAnimated:TRUE completion:nil];
    } else {
        if (info != nil) {
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            NSData *videoData = [NSData dataWithContentsOfURL:url];
            [self uploadVideo:videoData];
            
            AVURLAsset *as = [[AVURLAsset alloc] initWithURL:url options:nil];
            AVAssetImageGenerator *ima = [[AVAssetImageGenerator alloc] initWithAsset:as];
            ima.appliesPreferredTrackTransform = YES;
            NSError *err = NULL;
            CMTime time = CMTimeMake(0, 60);
            CGImageRef imgRef = [ima copyCGImageAtTime:time actualTime:NULL error:&err];
            UIImage *currentImg = [[UIImage alloc] initWithCGImage:imgRef];
            NSData *imageData = UIImagePNGRepresentation(currentImg);
            [self uploadImage:imageData];
            
            [self dismissViewControllerAnimated:NO completion:nil];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            confirm = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Do you want to upload the video?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [confirm show];
        }
    }
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == confirm) {
        if (buttonIndex == 0) {
            [self dismissViewControllerAnimated:NO completion:nil];
        } else {
            NSLog(@"Upload is called");
            [self upload];
        }
    }
}

#pragma mark - Profile Image Protocols

- (void)uploadProfileImage:(NSData*)imgData {
    if (imgData == nil){
        NSLog(@"image data is nil");
    } else {
        profileImageFile = [PFFile fileWithName:@"profile_image.png" data:imgData];
    }
}

- (void)findImage {
    pickerView2 = [[UIImagePickerController alloc] init];
    pickerView2.allowsEditing = true;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        [pickerView2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [pickerView2 setDelegate:self];
    [self presentViewController:pickerView2 animated:TRUE completion:nil];
}

- (void)getImage {
    PFUser *user = [PFUser currentUser];
    PFFile *profileImage = [user objectForKey:@"profileImage"];
    [profileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        imageData2 = data;
        if (imageData2 != nil)
        {
            NSLog(@"parse image");
            profile = [UIImage imageWithData:imageData2];
        } else {
            NSLog(@"local image");
            profile = [UIImage imageNamed:@"profile_image.png"];
        }
        UIImage *mask = [UIImage imageNamed:@"mask-new.png"];
        CALayer *amask = [CALayer layer];
        amask.contents = (id)[mask CGImage];
        amask.frame = CGRectMake(0, 0, profileImg.frame.size.width, profileImg.frame.size.height);
        profileImg.layer.mask = amask;
        profileImg.layer.masksToBounds = YES;
        profileImg.image = profile;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.beginTime = CACurrentMediaTime()+.25;
        animation.duration = .25;
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat:1.0f];
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeBoth;
        animation.additive = NO;
        [profileImg.layer addAnimation:animation forKey:@"opacityIN"];
    }];
}

- (void)performUpload {
    [SVProgressHUD showWithStatus:@"Uploading..." maskType:SVProgressHUDMaskTypeBlack];
    if (profileImageFile != nil){
        [profileImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                PFUser *user = [PFUser currentUser];
                [user setObject:profileImageFile forKey:@"profileImage"];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error)
                    {
                        NSLog(@"Image was saved");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DoProfileImageUpdate" object:nil userInfo:nil];
                    }
                }];
            } else {
                NSLog(@"Image was NOT saved");
            }
        } progressBlock:^(int percentDone) {
            float progress = (float)percentDone/100;
            NSLog(@"progress: %f", progress);
            if (progress >=1.0) {
                [SVProgressHUD dismiss];
            }
        }];
    }
}

- (void)updateProfileImage {
    [self getImage];
}

- (void)takePhoto {
    pickerView2 = [[UIImagePickerController alloc] init];
    pickerView2.allowsEditing = true;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [pickerView2 setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [pickerView2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [pickerView2 setDelegate:self];
    [self presentViewController:pickerView2 animated:TRUE completion:nil];
}

- (IBAction)changeProfilePhoto:(id)sender {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Change Photo" andMessage:nil];
    [alertView addButtonWithTitle:@"Find Photo"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"Find");
                              [self findImage];
                          }];
    [alertView addButtonWithTitle:@"Capture Photo"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"Capture");
                              [self takePhoto];
                          }];
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"User canceled");
                          }];
    [alertView show];
}

- (IBAction)profileClick:(id)sender {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * 1 * 1 ];
    rotationAnimation.duration = .3;
    rotationAnimation.cumulative = YES;
    [profileImg.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

#pragma mark - Upload

- (void)callForReload {
    NSLog(@"Reload MainView TableView Data");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DoReload" object:nil userInfo:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)doCamera {
    pickerView = [[UIImagePickerController alloc] init];
    pickerView.allowsEditing = YES;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [pickerView setSourceType:UIImagePickerControllerSourceTypeCamera];
        pickerView.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    } else {
        [pickerView setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        pickerView.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    }
    [pickerView setDelegate:self];
    [self navigationController:self.navigationController willShowViewController:pickerView animated:NO];
    [self presentViewController:pickerView animated:NO completion:nil];
}

- (void)doLibrary {
    pickerView = [[UIImagePickerController alloc] init];
    pickerView.allowsEditing = YES;
    [pickerView setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    pickerView.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    [pickerView setDelegate:self];
    [self presentViewController:pickerView animated:NO completion:nil];
}

- (IBAction)openVideoPickerView:(id)sender {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Upload Video" andMessage:nil];
    [alertView addButtonWithTitle:@"Find Video"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"Find Video");
                              [self doLibrary];
                          }];
    [alertView addButtonWithTitle:@"Capture Video"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"Capture Video");
                              [self doCamera];
                          }];
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"User canceled");
                          }];
    [alertView show];
}

- (void)uploadVideo:(NSData*)videoData
{
    if (videoData == nil){
        NSLog(@"video data is nil");
    }
    videoFile = [PFFile fileWithName:@"video.mov" data:videoData];
}

- (void)uploadImage:(NSData*)imageData
{
    if (imageData == nil){
        NSLog(@"image data is nil");
    }
    imageFile = [PFFile fileWithName:@"image.png" data:imageData];
}

- (void)upload {
    [SVProgressHUD showWithStatus:@"Uploading..." maskType:SVProgressHUDMaskTypeBlack];
    [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            int id_num = (arc4random()%1000)+1;
            NSString *theTitle = [NSString stringWithFormat:@"Title_%i - %@", id_num, [PFUser currentUser].username];
            PFObject *obj = [PFObject objectWithClassName:@"Feed"];
            [obj setObject:[PFUser currentUser] forKey:@"user"];
            [obj setObject:theTitle forKey:@"title"];
            [obj setObject:[NSDate date].description forKey:@"description"];
            [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"VIDEO SAVED!");
                } else {
                    NSLog(@"ERROR WITH VIDEO");
                }
            } progressBlock:^(int percentDone) {
                float progress = (float)percentDone/100;
                NSLog(@"video progress: %f", progress);
            }];
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"IMAGE SAVED!");
                } else {
                    NSLog(@"ERROR WITH IMAGE");
                }
            } progressBlock:^(int percentDone) {
                float progress = (float)percentDone/100;
                //[SVProgressHUD showProgress:progress status:@"Uploading" maskType:SVProgressHUDMaskTypeBlack];
                NSLog(@"image progress: %f", progress);
            }];
            [obj setObject:imageFile forKey:@"screenshot"];
            [obj setObject:videoFile forKey:@"video"];
            [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Alert" andMessage:@"There was a Problem. Try Again!"];
                    [alertView addButtonWithTitle:@"Done" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
                        NSLog(@"Cancel Clicked");
                    }];
                    [alertView show];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                    [self performSelector:@selector(callForReload) withObject:nil afterDelay:1.8];
                }
            }];
        } else {
            NSLog(@"ERROR UPLOADING VIDEO");
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    }];
}

@end
