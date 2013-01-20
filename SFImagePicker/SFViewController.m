//
//  SFViewController.m
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import "SFViewController.h"
#import "SFMultiImagePickerController.h"

@interface SFViewController ()

@end

@implementation SFViewController

@synthesize showPickerButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIScreen *s = [UIScreen mainScreen];
    [s scale];

    [showPickerButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPicker:(id)sender
{
    
    SFMultiImagePickerController *imagePicker = [[SFMultiImagePickerController alloc] init];
    imagePicker.delegate = self;
    [imagePicker setAllowedSelectionSize:8];
    [self presentViewController:imagePicker animated:YES completion:nil];    
}

#pragma mark -- sfImagePickerDelegate methods --
-(void)sfImagePickerContoller:(SFMultiImagePickerController *)imagePicker didFinishWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sfImagePickerContollerDidCancel:(SFMultiImagePickerController *)imagePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end