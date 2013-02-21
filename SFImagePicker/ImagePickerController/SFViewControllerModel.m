//
//  SFViewControllerModel.m
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import "SFViewControllerModel.h"

@interface SFViewControllerModel() {
    
}

-(NSString*) getUriForAsset:(ALAsset*)asset;

@end;

@implementation SFViewControllerModel

@synthesize allowedSelectionSize, assetsLibrary, assetGroups, selectedGroup;
@synthesize selectedGroupAssets;
@synthesize selectedOverlayImage;

-(id) init {
    self = [super init];
    if(self) {
        self.assetGroups = [[NSMutableArray alloc] init];
        self.selectedGroupAssets = [[NSMutableArray alloc] init];
        self.selectedAssetUris = [[NSMutableArray alloc] init];
        self.selectedAssets = [[NSMutableDictionary alloc] init];
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

-(void)selectAsset:(ALAsset*)asset {
    NSString *url = [self getUriForAsset:asset];
    if( [self.selectedAssetUris indexOfObject:url] == NSNotFound ){
        [self.selectedAssetUris addObject:url];
        [self.selectedAssets setObject:asset forKey:url];
    }
}

-(void)deselectAsset:(ALAsset*)asset {
    NSString *url = [self getUriForAsset:asset];
    if( [self.selectedAssetUris indexOfObject:url] != NSNotFound ){
        [self.selectedAssets removeObjectForKey:url];
        [self.selectedAssetUris removeObject:url];
    }
}

-(BOOL)isSelectedAsset:(ALAsset *)asset {
    NSURL *url_ = [asset valueForProperty:ALAssetPropertyAssetURL];
    NSString *url = url_.absoluteString;
    return ( [self.selectedAssetUris indexOfObject:url] != NSNotFound );
}

-(void)notifyAboutChange {
    NSNotification *notification = [NSNotification notificationWithName:MODEL_CHANGED object:nil];
    [self postNotification:notification];
}

- (NSString *)getUriForAsset:(ALAsset *)asset {
    NSURL *url_ = [asset defaultRepresentation].url;
    NSString *url = url_.absoluteString;
    return url;
}

-(void)dealloc
{
    [self.assetGroups removeAllObjects];
    self.assetGroups = nil;
    
    [self.selectedGroupAssets removeAllObjects];
    self.selectedGroupAssets = nil;
    
    [self.selectedAssetUris removeAllObjects];
    self.selectedAssetUris = nil;
    
    [self.selectedAssets removeAllObjects];
    self.selectedAssets = nil;
}

@end
