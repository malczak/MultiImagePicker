//
//  SFViewControllerModel.h
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define MODEL_CHANGED @"ModelChanged"

// http://stackoverflow.com/questions/10836463/when-to-use-nsnotificationcenter

@interface SFViewControllerModel : NSNotificationCenter

@property (nonatomic) UInt16 allowedSelectionSize;

@property (nonatomic, retain) UIImage *selectedOverlayImage;

@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, retain) NSMutableArray *assetGroups;

@property (nonatomic, retain) ALAssetsGroup *selectedGroup;

@property (nonatomic, retain) NSMutableArray *selectedGroupAssets;

@property (nonatomic, retain) NSMutableArray *selectedAssetUris;

@property (nonatomic, retain) NSMutableDictionary *selectedAssets;

-(void)selectAsset:(ALAsset*)asset;

-(void)deselectAsset:(ALAsset*)asset;

-(BOOL)isSelectedAsset:(ALAsset *)asset;

-(void)notifyAboutChange;

@end
