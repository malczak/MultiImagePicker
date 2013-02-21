//
//  SFAssetTableViewController.m
//  SFImagePicker
//
//  Created by malczak on 1/8/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import "SFAssetTableViewController.h"
#import "SFAssetTableCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SFAssetTableViewController ()

@end

@implementation SFAssetTableViewController

@synthesize model, delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHander:)]
        ;
        tapRecognizer.cancelsTouchesInView = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.multipleTouchEnabled = YES;
    [self.tableView addGestureRecognizer:tapRecognizer];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tapHander:(UIGestureRecognizer*)recognizer
{
    tapLocation = [tapRecognizer locationInView:self.tableView];
}

-(void)setModel:(SFViewControllerModel *)value {
    if(self.model) {
        [self.model removeObserver:self];
    }
    model = value;
    if(self.model) {
        [self.model addObserver:self selector:@selector(modelHasChanged:) name:MODEL_CHANGED object:nil];
    }
}

-(void) modelHasChanged:(NSNotification*)notificationCenter
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger) floorf( [model.selectedGroupAssets count] / 4.0f );
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 79;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    int realOffset = row * 4;
    
    static NSString *CellIdentifier = @"Cell";
    SFAssetTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell==nil) {
        cell = [[SFAssetTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // add items offset and udpate cell
    cell.model = model;
    cell.dataOffset = realOffset;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    SFAssetTableCell *cell = (SFAssetTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"cell offset %d", cell.dataOffset);
    // :D
    CGPoint cellPoint = [cell convertPoint:tapLocation fromView:self.tableView];
    int assetIndex = [cell assetOffsetFromPoint:cellPoint];
    if( (assetIndex>=0) && (assetIndex<[self.model.selectedGroupAssets count]) ) {
        ALAsset *asset = [self.model.selectedGroupAssets objectAtIndex:assetIndex];
        [self.delegate userSelectedAsset:asset];
        // we be updated by model notification
//        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)dealloc {
    self.delegate = nil;
    self.model = nil;
}
@end
