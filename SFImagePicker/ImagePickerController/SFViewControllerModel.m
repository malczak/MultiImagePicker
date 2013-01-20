//
//  SFViewControllerModel.m
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import "SFViewControllerModel.h"

@implementation SFViewControllerModel

@synthesize allowedSelectionSize, assetsLibrary, assetGroups, selectedGroup;
@synthesize selectedGroupAssets;
@synthesize selectedOverlayImage;

-(id) init {
    self = [super init];
    if(self) {
        self.assetGroups = [[NSMutableArray alloc] init];
        self.selectedGroupAssets = [[NSMutableArray alloc] init];
        self.selectedAssets = [[NSMutableArray alloc] init];
        self.allowedSelectionSize = 1;
    }
    return self;
}

-(void) setAllowedSelectionSize:(UInt16)value {
    allowedSelectionSize = MAX( 1, value);
}

-(void) setSelectedGroup:(ALAssetsGroup *)value {
    selectedGroup = value;
    [selectedGroupAssets removeAllObjects];
    // clear instances
}

-(BOOL)isSelectedAsset:(ALAsset *)asset {
    id url = [asset valueForProperty:ALAssetPropertyAssetURL];
    return ( [self.selectedAssets indexOfObject:url] != NSNotFound );
}

-(void)notifyAboutChange {
    NSNotification *notification = [NSNotification notificationWithName:MODEL_CHANGED object:nil];
    [self postNotification:notification];
}

-(void)dealloc
{
    [self.assetGroups removeAllObjects];
    self.assetGroups = nil;
    
    [self.selectedGroupAssets removeAllObjects];
    self.selectedGroupAssets = nil;
    
    [self.selectedAssets removeAllObjects];
    self.selectedAssets = nil;
}

@end
