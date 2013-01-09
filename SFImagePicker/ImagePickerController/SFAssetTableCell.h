//
//  SFAssetTableCell.h
//  SFImagePicker
//
//  Created by malczak on 1/8/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "SFViewControllerModel.h"
#import "SFAssetsControllerDelegate.h"

@interface SFAssetTableCell : UITableViewCell {
}

@property (nonatomic, retain) SFViewControllerModel *model;

@property (nonatomic, retain) id<SFAssetsControllerDelegate> delegate;

@property (nonatomic, assign) int dataOffset;

-(int)assetOffsetFromPoint:(CGPoint)point;

@end
