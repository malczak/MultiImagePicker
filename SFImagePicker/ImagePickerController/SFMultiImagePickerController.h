//
//  SFMultiImagePickerController.h
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFViewControllerModel.h"
#import "SFAssetsControllerDelegate.h"
#import "SFDragIndicator.h"


#define SELECTED_THUMB_SIZE 75
#define SELECTED_THUMBS_GAP 4
#define REMOVE_DRAGGED_ELEMENT_DIST 40.0f

@interface SFMultiImagePickerController : UIViewController <SFAssetsControllerDelegate> {
    UINavigationController *navigationController;
    UIScrollView *selectedAssetsView;
    UILabel *emptySelectionPrompt;

    NSMutableArray *selectedAssetsThumbnails;

    // gesture recognizers
    UITapGestureRecognizer *tapRecognizer;
    UILongPressGestureRecognizer *pressRecognizer;

    CGPoint mousePosition;
    NSTimer *autoScrollTimer;

    // drag&drop
    SFDragIndicator *dragIndicator;
    
    SFViewControllerModel *model;
}

@property (nonatomic, retain) id delegate;

-(void)userSelectedGroup:(ALAssetsGroup *)group;

-(void)userSelectedAsset:(ALAsset *)asset;


-(void)setAllowedSelectionSize:(UInt16)value;
-(UInt16)getAllowedSelectionSize;

@end


@protocol SFMultiImagePickerDelegate <NSObject>

-(void) sfImagePickerContollerDidCancel:(SFMultiImagePickerController *) imagePicker;
-(void) sfImagePickerContoller:(SFMultiImagePickerController *) imagePicker didFinishWithInfo:(NSArray *)info;

@end



