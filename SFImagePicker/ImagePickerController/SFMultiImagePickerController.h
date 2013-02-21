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

#ifndef SF_FLAGS
#define SF_FLAGS
    extern NSString *const SFImagePickerControllerMediaType;       // an NSString (UTI, i.e. kUTTypeImage)
    extern NSString *const SFImagePickerControllerOriginalImage;   // a UIImage
    extern NSString *const SFImagePickerControllerFullScreenImage; // a UIImage as returned by ALAssetRepresentation.fullScreenImage
    extern NSString *const SFImagePickerControllerReferenceURL;    // an NSURL that references an asset in the AssetsLibrary framework
    extern NSString *const SFImagePickerControllerAsset;           // a ALAsset instance representing a resource
#endif


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
@property (nonatomic, assign) BOOL includeOriginalImages;
@property (nonatomic, assign) BOOL includeFullScreenImages;
@property (nonatomic, assign) BOOL includeAsset;

-(void)userSelectedGroup:(ALAssetsGroup *)group;

-(void)userSelectedAsset:(ALAsset *)asset;


-(void)setAllowedSelectionSize:(UInt16)value;
-(UInt16)getAllowedSelectionSize;

@end


@protocol SFMultiImagePickerDelegate <NSObject>

-(void) imagePickerContollerDidCancel:(SFMultiImagePickerController *) imagePicker;
-(void) imagePickerContoller:(SFMultiImagePickerController *) imagePicker didFinishPickingMediaWithInfo:(NSArray *)info;


@end



