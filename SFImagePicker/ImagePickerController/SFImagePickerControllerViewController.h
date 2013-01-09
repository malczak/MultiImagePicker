//
//  SFImagePickerControllerViewController.h
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFViewControllerModel.h"
#import "SFAssetsControllerDelegate.h"

@interface SFImagePickerControllerViewController : UIViewController <SFAssetsControllerDelegate> {
    UINavigationController *navigationController;
    UIScrollView *selectedAssetsView;
    UILabel *emptySelectionPrompt;
    
    SFViewControllerModel *model;
}

@property (nonatomic, retain) id delegate;

-(void)userSelectedGroup:(ALAssetsGroup *)group;

-(void)userSelectedAsset:(ALAsset *)asset;


-(void)setAllowedSelectionSize:(UInt16)value;
-(UInt16)getAllowedSelectionSize;

@end


@protocol SFImagePickerDelegate <NSObject>

-(void) sfImagePickerContollerDidCancel:(SFImagePickerControllerViewController*) imagePicker;
-(void) sfImagePickerContoller:(SFImagePickerControllerViewController*) imagePicker didFinishWithInfo:(NSArray *)info;

@end



