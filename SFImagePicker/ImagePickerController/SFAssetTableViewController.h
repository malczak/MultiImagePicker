//
//  SFAssetTableViewController.h
//  SFImagePicker
//
//  Created by malczak on 1/8/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFViewControllerModel.h"
#import "SFAssetsControllerDelegate.h"

@interface SFAssetTableViewController : UITableViewController {
    CGPoint tapLocation;
    UITapGestureRecognizer *tapRecognizer;
}

@property (nonatomic, retain) SFViewControllerModel *model;

@property (nonatomic, retain) id<SFAssetsControllerDelegate> delegate;

@end
