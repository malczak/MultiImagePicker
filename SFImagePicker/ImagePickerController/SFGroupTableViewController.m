//
//  SFGroupTableViewController.m
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import "SFGroupTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation SFGroupTableViewController

@synthesize delegate;

- (void)viewDidLoad {
//    [self.tableView reloadData];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.model.assetGroups count];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"groupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    ALAssetsGroup *group = [self.model.assetGroups objectAtIndex:[indexPath row]];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
    NSInteger numAssets = [group numberOfAssets];
    
    NSString *title = [NSString stringWithFormat:@"%@ (%d)", groupName, numAssets];
    
    cell.textLabel.text = title;
    cell.imageView.image = [[UIImage alloc] initWithCGImage:[group posterImage]]; // should be autorelease
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate != nil) {
        NSInteger row = [indexPath row];
        ALAssetsGroup *group = [self.model.assetGroups objectAtIndex:row];
        [self.delegate userSelectedGroup:group];
    }
}

- (void)dealloc {
    self.delegate = nil;
    self.model = nil;
}



@end
