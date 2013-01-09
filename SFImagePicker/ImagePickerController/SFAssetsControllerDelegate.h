//
//  SFAssetsControllerDelegate.h
//  SFImagePicker
//
//  Created by malczak on 1/8/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


@protocol SFAssetsControllerDelegate <NSObject>

-(void)userSelectedGroup:(ALAssetsGroup*) group;

-(void)userSelectedAsset:(ALAsset*) asset;

@end
