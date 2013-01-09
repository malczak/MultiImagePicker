//
//  SFViewControllerModel.h
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SFViewControllerModel : NSObject

@property (nonatomic) UInt16 allowedSelectionSize;

@property (nonatomic, retain) UIImage *selectedOverlayImage;

@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, retain) NSMutableArray *assetGroups;

@property (nonatomic, retain) ALAssetsGroup *selectedGroup;

@property (nonatomic, retain) NSMutableArray *selectedGroupAssets;

@property (nonatomic, retain) NSMutableArray *selectedAssets;

@property (nonatomic, retain) NSMutableArray *selectedAssetsThumbnails;

@end
