//
//  SFViewController.h
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFImagePickerControllerViewController.h"

@interface SFViewController : UIViewController <SFImagePickerDelegate>

@property (nonatomic, retain) IBOutlet UIButton *showPickerButton;

-(void)sfImagePickerContoller:(SFImagePickerControllerViewController *)imagePicker didFinishWithInfo:(NSArray *)info;
-(void)sfImagePickerContollerDidCancel:(SFImagePickerControllerViewController *)imagePicker;

@end
