//
//  SFViewController.m
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import "SFViewController.h"
#import "SFImagePickerControllerViewController.h"

@interface SFViewController ()

@end

@implementation SFViewController

@synthesize showPickerButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [showPickerButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPicker:(id)sender
{
    
    SFImagePickerControllerViewController *imagePicker = [[SFImagePickerControllerViewController alloc] init];
    imagePicker.delegate = self;
    [imagePicker setAllowedSelectionSize:8];
    [self presentViewController:imagePicker animated:YES completion:nil];    
}

#pragma mark -- sfImagePickerDelegate methods --
-(void)sfImagePickerContoller:(SFImagePickerControllerViewController *)imagePicker didFinishWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sfImagePickerContollerDidCancel:(SFImagePickerControllerViewController *)imagePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end