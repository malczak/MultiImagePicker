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

-(void)imagePickerContoller:(SFMultiImagePickerController *)imagePicker didFinishPickingMediaWithInfo:(NSArray *)info;
-(void)imagePickerContollerDidCancel:(SFMultiImagePickerController *)imagePicker;

@end
