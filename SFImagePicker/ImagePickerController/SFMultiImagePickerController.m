//
//  SFMultiImagePickerController.m
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#import "SFMultiImagePickerController.h"
#import "SFViewControllerModel.h"
#import "SFGroupTableViewController.h"
#import "SFAssetTableViewController.h"
#import "SelectedAssetView.h"

/**
 
 http://stackoverflow.com/questions/2962162/non-fullscreen-uinavigationcontroller
 http://stackoverflow.com/questions/2526990/adding-a-uinavigationcontroller-as-a-subview-of-uiview
 
 http://stackoverflow.com/questions/8084050/when-to-use-addchildviewcontroller-vs-pushviewcontroller
 
  [      ]
  [ Nav. ]
  [      ]
  [______]
  [ sel. ]
 
 */

@interface SFMultiImagePickerController ()

@end

@implementation SFMultiImagePickerController

@synthesize delegate;

-(id) init {
    self = [super init];
    if(self) {
        model = [[SFViewControllerModel alloc] init];
        selectedAssetsThumbnails = [[NSMutableArray alloc] init];

        dragIndicator = [[SFDragIndicator alloc] init];

        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        tapRecognizer.cancelsTouchesInView = YES;

        pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureLongPress:)];
        pressRecognizer.numberOfTouchesRequired = 1;
        pressRecognizer.minimumPressDuration = 0.3;
        pressRecognizer.cancelsTouchesInView = YES;

    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    CGRect frm =  [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:frm];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor redColor];
    self.view.bounds = CGRectMake(0,0,frm.size.width,frm.size.height);
    
    UIImage *selectedOverlayImage = [UIImage imageNamed:@"Overlay.png"];
    model.selectedOverlayImage = selectedOverlayImage;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect viewRect = self.view.frame;
    CGFloat navHeight = viewRect.size.height - 90;

    // create main navigation controller to display assets
    navigationController = [[UINavigationController alloc] init];
    
//	[cancelButton release];
    
    [self addChildViewController:navigationController];
    [self.view addSubview:navigationController.view];
    navigationController.view.frame = CGRectMake(0, 0, viewRect.size.width, navHeight);
    
    
    CGRect selectedRect = CGRectMake(0, navHeight, viewRect.size.width, viewRect.size.height - navHeight);
    //create selected assets scroll view
    selectedAssetsView = [[UIScrollView alloc] initWithFrame:selectedRect];
    selectedAssetsView.showsHorizontalScrollIndicator = NO;
    selectedAssetsView.showsVerticalScrollIndicator = NO;
    selectedAssetsView.pagingEnabled = NO;
    selectedAssetsView.bounces = NO;
    selectedAssetsView.alwaysBounceHorizontal = NO;
    selectedAssetsView.alwaysBounceVertical = NO;
    selectedAssetsView.scrollsToTop = NO;
    selectedAssetsView.backgroundColor = [UIColor whiteColor];
    [selectedAssetsView addGestureRecognizer:tapRecognizer];
    [selectedAssetsView addGestureRecognizer:pressRecognizer];
    [self.view addSubview:selectedAssetsView];

    //empty selection prompt
    emptySelectionPrompt = [[UILabel alloc] initWithFrame:selectedRect];
    emptySelectionPrompt.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    emptySelectionPrompt.textAlignment = NSTextAlignmentCenter;
    emptySelectionPrompt.text = [NSString stringWithFormat:@"Select up to %d photos", [self getAllowedSelectionSize]];
    CALayer *layer = emptySelectionPrompt.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.8;
    layer.shadowRadius = 4;
    layer.shouldRasterize = YES;
    [self.view addSubview:emptySelectionPrompt];
    
    
    // initialize assets library access
    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
    model.assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    // get array of all available groups
    void (^completeBlock)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        // finished
        if(group == nil) {
            [self performSelectorOnMainThread:@selector(groupEnummerationDone) withObject:nil waitUntilDone:YES];
//            dispatch_async( dispatch_get_main_queue(), ^(void){
//                [self groupEnummerationDone];
//            });
            return;
        }
        
        [model.assetGroups addObject: group];
        NSLog(@"Num : %d", [model.assetGroups count]);
    };
    
    void (^failureBlock)(NSError *error) = ^(NSError *error) {
        // alert ;/
        NSLog(@"error");
    };
    
    [model.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:completeBlock failureBlock:failureBlock];
    
}

- (void)handleGestureTap:(UIGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {

        SelectedAssetView *v = [self viewFromRecognizer:recognizer];
        if (v) {
            NSLog(@"Tap");
        }

    }
}

- (void)handleGestureLongPress:(UITapGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {

        SelectedAssetView *selectedThumb;

        if ( recognizer.state == UIGestureRecognizerStateBegan ) {

            selectedThumb = [self viewFromRecognizer:recognizer];
            if (selectedThumb) {

                selectedThumb.dragged = YES;

                selectedAssetsView.scrollEnabled = NO;


                UIImage *dragIndicatorImage = [UIImage imageWithCGImage:selectedThumb.asset.thumbnail];

                CGRect frame = [recognizer.view convertRect:selectedThumb.frame toView:self.view];
                CGPoint mousePosition = [recognizer locationInView:self.view];
                float dx = frame.size.width - 5;
                float dy = frame.size.height - 5;
                frame.origin.x = mousePosition.x - dx;
                frame.origin.y = mousePosition.y - dy;

                dragIndicator.image = dragIndicatorImage;
                dragIndicator.relatedData = selectedThumb;
                dragIndicator.frame = frame;

                [self.view addSubview:dragIndicator];


                selectedAssetsView.scrollEnabled = YES;

            }
        } else
        if ( recognizer.state == UIGestureRecognizerStateChanged ) {
            CGRect frame = dragIndicator.frame;
            CGPoint mousePosition = [recognizer locationInView:self.view];
            float dx = frame.size.width - 5;
            float dy = frame.size.height - 5;
            frame.origin.x = mousePosition.x - dx;
            frame.origin.y = mousePosition.y - dy;
            dragIndicator.frame = frame;

            // ? dragged out to delete
            CGRect selectedViewFrame = selectedAssetsView.frame;
            float distance = ( selectedViewFrame.origin.y - mousePosition.y );
            if (distance > REMOVE_DRAGGED_ELEMENT_DIST ) {
                dragIndicator.alpha = 0.4;
            } else{
                dragIndicator.alpha = 1.0;
            }

            //try to calc new index
            float scrollViewDragOffset = selectedAssetsView.contentOffset.x + mousePosition.x;
            float newDropMinOffset = 0;
            float newDropMaxOffset = 0;
            int selectedCount = [selectedAssetsThumbnails count];
            int dropIndex = 0;
            while (dropIndex<selectedCount) {
                SelectedAssetView *thumb = [selectedAssetsThumbnails objectAtIndex:dropIndex];

                newDropMinOffset = newDropMaxOffset;
                newDropMaxOffset = thumb.frame.origin.x + thumb.frame.size.width * 0.5;

                NSLog(@"new %d/%d is %f<>%f | %f",dropIndex,selectedCount,newDropMinOffset,newDropMaxOffset,scrollViewDragOffset);

                if ( (scrollViewDragOffset > newDropMinOffset) && (scrollViewDragOffset < newDropMaxOffset) ) {
                    NSLog(@"New index should be %d",dropIndex);
                    int dragIndex = [selectedAssetsThumbnails indexOfObject:dragIndicator.relatedData];
                    [selectedAssetsThumbnails exchangeObjectAtIndex:dragIndex withObjectAtIndex:dropIndex];
                    [self layoutSelectedAssets];
                    break;
                }

                dropIndex+=1;
            }

        } else
        if ( recognizer.state == UIGestureRecognizerStateEnded ) {
            [dragIndicator removeFromSuperview];

            selectedThumb = (SelectedAssetView *)dragIndicator.relatedData;
            selectedThumb.dragged = NO;

            //check if should be removed / if not calc new index :P
            CGPoint mousePosition = [recognizer locationInView:self.view];
            CGRect selectedViewFrame = selectedAssetsView.frame;
            float distance = ( selectedViewFrame.origin.y - mousePosition.y );

            if (distance > REMOVE_DRAGGED_ELEMENT_DIST ) {
                [self userSelectedAsset:selectedThumb.asset];
                /// update somehow a table view
            } else {

            }

            selectedAssetsView.contentOffset = CGPointMake(10, 0);


            dragIndicator.image = nil;
            dragIndicator.relatedData = nil;
        }


    }
}

- (SelectedAssetView *)viewFromRecognizer:(UIGestureRecognizer *)recognizer {
    CGPoint tapPosition = [recognizer locationInView:recognizer.view];
    for ( SelectedAssetView *selectedView in selectedAssetsThumbnails) {
        CGRect frame = selectedView.frame;
        if (CGRectContainsPoint(frame, tapPosition)) {
            NSString *name0 = [NSString stringWithUTF8String:object_getClassName(recognizer)];
            NSString *name1 = [NSString stringWithUTF8String:object_getClassName(selectedView)];
            NSLog(@"%@ detected on - %@", name0, name1);
            return selectedView;
        }
    }
    return nil;
}

- (void)groupEnummerationDone
{
    SFGroupTableViewController *groupTableViewController = [[SFGroupTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self createDefaultButtonsInNavigation:groupTableViewController.navigationItem withCancel:YES];
    groupTableViewController.delegate = self;
    groupTableViewController.model = model;
    [navigationController pushViewController:groupTableViewController animated:YES];
}

- (void)assetsEnummerationDone
{
    SFAssetTableViewController *assetTableViewController = [[SFAssetTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self createDefaultButtonsInNavigation:assetTableViewController.navigationItem withCancel:NO];
    assetTableViewController.delegate = self;
    assetTableViewController.model = model;
    [navigationController pushViewController:assetTableViewController animated:YES];
}

-(void)createDefaultButtonsInNavigation:(UINavigationItem*) navigationItem withCancel:(BOOL) cancel
{
    
    if(cancel == YES) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelImagePicker)];
        [navigationItem setLeftBarButtonItem:cancelButton];
    }

    UIBarButtonItem *acceptButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(acceptImagePicker)];
	[navigationItem setRightBarButtonItem:acceptButton];   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -- Delegate user decisions --
-(void) cancelImagePicker
{
    if( [self.delegate respondsToSelector:@selector(sfImagePickerContollerDidCancel:)] ) {
        [self.delegate performSelector:@selector(sfImagePickerContollerDidCancel:) withObject:self];
    }
}

-(void) acceptImagePicker
{
    if( [self.delegate respondsToSelector:@selector(sfImagePickerContoller:didFinishWithInfo:)] ) {

        // selected assets NSURL's
        NSArray* info = [NSArray arrayWithArray:model.selectedAssets];
/*
        NSMutableArray *returnArray = [[[NSMutableArray alloc] init] autorelease];
        
        for(ALAsset *asset in model.sele) {
            
            NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
            [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
            [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
            [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
            
            [returnArray addObject:workingDictionary];
            
            [workingDictionary release];
        }
 */
        
        
        [self.delegate performSelector:@selector(sfImagePickerContoller:didFinishWithInfo:) withObject:self withObject:[NSArray arrayWithObject:info]];
    }
}



#pragma mark -- Allowed selection size getter/setter --
-(void)setAllowedSelectionSize:(UInt16)value {
    model.allowedSelectionSize = value;
}

-(UInt16)getAllowedSelectionSize {
    return model.allowedSelectionSize;
}


#pragma mark -- SFAssetsControllerDelegate --

-(void)userSelectedGroup:(ALAssetsGroup *)group
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    model.selectedGroup = group;
    
    void (^completeBlock)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result == nil) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self assetsEnummerationDone];
            });
            return;
        }
        
        [model.selectedGroupAssets addObject:result];
    };
    
    [model.selectedGroup enumerateAssetsUsingBlock:completeBlock];
}

-(void)userSelectedAsset:(ALAsset *)asset
{
    if(asset == nil) {
        return;
    }
    
    // if selected deselect
    SelectedAssetView *thumb;
    id url = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    NSUInteger selectedCount = [model.selectedAssets count];
    NSUInteger selectedIndex = [model.selectedAssets indexOfObject:url];

    if( selectedIndex != NSNotFound ) {

        thumb = (SelectedAssetView*)[selectedAssetsThumbnails objectAtIndex:selectedIndex];
        [thumb removeFromSuperview];
        [selectedAssetsThumbnails removeObjectAtIndex:selectedIndex];
        //remove
            
        [model.selectedAssets removeObjectAtIndex:selectedIndex];

        // update
        [self layoutSelectedAssets];

        // scroll to closest to removed one
        thumb = [selectedAssetsThumbnails objectAtIndex:MIN(selectedIndex, selectedCount-2)];
        CGRect lastFrame = thumb.frame;
        lastFrame = CGRectOffset(lastFrame, 5, 0);
        [selectedAssetsView scrollRectToVisible:lastFrame animated:NO];


    } else
    if ( selectedCount < model.allowedSelectionSize) {

        emptySelectionPrompt.hidden = YES;

        CGSize thumbSize = CGSizeMake(75, 75);
        
        thumb = [[SelectedAssetView alloc] initWithFrame:CGRectMake(0, 0, thumbSize.width, thumbSize.height) andAsset:asset];
        [selectedAssetsView addSubview:thumb];
        [selectedAssetsThumbnails addObject:thumb];

        [model.selectedAssets addObject:url];

        // update
        [self layoutSelectedAssets];

        // scroll to show last element
        CGRect lastFrame = thumb.frame;
        lastFrame = CGRectOffset(lastFrame, 5, 0);
        [selectedAssetsView scrollRectToVisible:lastFrame animated:NO];

    } else {
        //show info
        emptySelectionPrompt.hidden = NO;
        emptySelectionPrompt.alpha = 0.0;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionCurveEaseInOut
                         animations:^(void) {
                             [UIView setAnimationRepeatCount:0.8f];
                             emptySelectionPrompt.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 emptySelectionPrompt.alpha = 1.0;
                                 emptySelectionPrompt.hidden = YES;
                             }
                         }];

    }
    

}

#pragma mark -- Upadate selected assets view --

-(void)updateSelectedAssetsView {
    int assetsCount = [model.selectedAssets count];
    
    emptySelectionPrompt.hidden = (assetsCount>0);

    //NSArray *thumbs = selectedAssetsView.subviews;

    CGSize thumbSize = CGSizeMake(75, 75);

    selectedAssetsView.contentSize = CGSizeMake( (thumbSize.width + 4) * assetsCount - 4, thumbSize.height);
    
    int index = 0;
    while ( index < assetsCount ) {
        ALAsset *asset = [model.selectedAssets objectAtIndex:index];
        UIImage *thumbImage = [UIImage imageWithCGImage:asset.thumbnail];
        UIImageView *thumb = [[UIImageView alloc] initWithFrame:CGRectMake( (thumbSize.width + 4) * index , 0, thumbSize.width, thumbSize.height)];
        thumb.image = thumbImage;
        [selectedAssetsView addSubview:thumb];
        index += 1;
    }
}

-(void) layoutSelectedAssets {
    
    UIView *thumb = nil;
    
    int count = [selectedAssetsThumbnails count];
    
    
    NSLog(@"count %d",count);

    if(count) {
        float X = 4;
        int index = 0;
        
        while(index<count) {
            thumb = [selectedAssetsThumbnails objectAtIndex:index];
            thumb.frame = CGRectMake( X, 4, thumb.bounds.size.width, thumb.bounds.size.height);
            NSLog(@" %f + %f",X,thumb.frame.size.width);
            X += 75 + 4;
            index += 1;
        }
        
        selectedAssetsView.contentSize = CGSizeMake( X, thumb.frame.size.height);
    }
   
}

-(void)dealloc
{
    self.delegate = nil;
    model = nil;
}

@end
