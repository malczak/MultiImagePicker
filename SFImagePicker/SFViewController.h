//
//  SFViewController.h
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFMultiImagePickerController.h"

@interface SFViewController : UIViewController <SFMultiImagePickerDelegate>

@property (nonatomic, retain) IBOutlet UIButton *showPickerButton;

-(void)sfImagePickerContoller:(SFMultiImagePickerController *)imagePicker didFinishWithInfo:(NSArray *)info;
-(void)sfImagePickerContollerDidCancel:(SFMultiImagePickerController *)imagePicker;

@end
