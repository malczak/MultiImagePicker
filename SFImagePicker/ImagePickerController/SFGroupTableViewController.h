//
//  SFGroupTableViewController.h
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFViewControllerModel.h"
#import "SFAssetsControllerDelegate.h"

@interface SFGroupTableViewController : UITableViewController

@property (nonatomic, retain) SFViewControllerModel *model;

@property (nonatomic, retain) id<SFAssetsControllerDelegate> delegate;

@end
